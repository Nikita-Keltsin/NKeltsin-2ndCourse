package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"strconv"
	"time"

	"golang.org/x/crypto/bcrypt"
	_ "github.com/jackc/pgx/v5/stdlib"
)

const (
	DB_USER     = "NIKAd"
	DB_PASSWORD = "20166614YANA"        
	DB_NAME     = "attendance" 
)

var db *sql.DB


type User struct {
	ID       int
	Username string
	Role     string
	GroupID  int
}

type Lesson struct {
	ID        int
	Subject   string
	TimeStart string
	TimeEnd   string
	Teacher   string
	Room      string
}

type JournalRow struct {
	StudentID   int
	StudentName string
	Marks       map[int]bool
}

type TeacherGroupRow struct {
	ID       int
	Name     string
	Students int
	Lessons  int
}

type GroupScheduleRow struct {
	ID      int
	Day     int
	Subject string
	Time    string
}

type AdminUserRow struct {
	ID       int
	Username string
	Role     string
	Group    string
}

func getCurrentWeek() int {
	// базовая дата только для вычисления относительного номера недели
	start, _ := time.Parse("2006-01-02", "2006-09-01")
	_, cur := time.Now().ISOWeek()
	_, sw := start.ISOWeek()
	w := cur - sw + 1
	if w < 1 {
		return 1
	}
	if w > 17 {
		return 17
	}
	return w
}

func getWeekType(week int) string {
	if week%2 == 0 {
		return "denominator"
	}
	return "numerator"
}

func render(w http.ResponseWriter, name string, data interface{}) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	t, err := template.ParseFiles("dashboard.html")
	if err != nil {
		http.Error(w, "Ошибка шаблона: "+err.Error(), http.StatusInternalServerError)
		return
	}
	if err := t.ExecuteTemplate(w, name, data); err != nil {
		log.Println("template error:", err)
	}
}
// роутер по ролям
func indexHandler(w http.ResponseWriter, r *http.Request) {
	c, err := r.Cookie("user_id")
	if err != nil {
		http.Redirect(w, r, "/login", http.StatusFound)
		return
	}
	uid, _ := strconv.Atoi(c.Value)

	var user User
	var groupName string

	err = db.QueryRow(`
		SELECT u.id, u.username, COALESCE(u.role,'starosta'),
		       COALESCE(u.group_id,0), COALESCE(g.name,'')
		FROM users u
		LEFT JOIN groups g ON u.group_id = g.id
		WHERE u.id = $1
	`, uid).Scan(&user.ID, &user.Username, &user.Role, &user.GroupID, &groupName)
	if err != nil {
		http.Redirect(w, r, "/login", http.StatusFound)
		return
	}

	switch user.Role {
	case "teacher":
		teacherPanelHandler(w, user)
	case "admin":
		adminPanelHandler(w, user)
	default:
		starostaDashboardHandler(w, r, user, groupName)
	}
}

// панель старосты: расписание своей группы
func starostaDashboardHandler(w http.ResponseWriter, r *http.Request, user User, groupName string) {
	selectedWeek := getCurrentWeek()
	if s := r.URL.Query().Get("week"); s != "" {
		if v, err := strconv.Atoi(s); err == nil && v >= 1 && v <= 17 {
			selectedWeek = v
		}
	}
	weekType := getWeekType(selectedWeek)

	rows, _ := db.Query(`
		SELECT id, day_of_week, subject_name, start_time, end_time, teacher_name, classroom
		FROM schedule
		WHERE group_id = $1 AND week_type = $2
		ORDER BY day_of_week, start_time
	`, user.GroupID, weekType)

	schedule := make(map[int][]Lesson)
	if rows != nil {
		defer rows.Close()
		for rows.Next() {
			var l Lesson
			var day int
			rows.Scan(&l.ID, &day, &l.Subject, &l.TimeStart, &l.TimeEnd, &l.Teacher, &l.Room)
			schedule[day] = append(schedule[day], l)
		}
	}

	var weeks []int
	for i := 1; i <= 17; i++ {
		weeks = append(weeks, i)
	}

	data := map[string]interface{}{
		"User":         user,
		"GroupName":    groupName,
		"Schedule":     schedule,
		"SelectedWeek": selectedWeek,
		"WeekType":     weekType,
		"Weeks17":      weeks,
	}
	render(w, "dashboard", data)
}

// панель преподавателя: список групп
func teacherPanelHandler(w http.ResponseWriter, user User) {
	rows, _ := db.Query(`
		SELECT g.id, g.name,
		       COUNT(DISTINCT s.id)   AS students,
		       COUNT(DISTINCT sch.id) AS lessons
		FROM groups g
		LEFT JOIN students s ON s.group_id = g.id
		LEFT JOIN schedule sch ON sch.group_id = g.id
		GROUP BY g.id, g.name
		ORDER BY g.id
	`)
	var groups []TeacherGroupRow
	for rows != nil && rows.Next() {
		var r TeacherGroupRow
		rows.Scan(&r.ID, &r.Name, &r.Students, &r.Lessons)
		groups = append(groups, r)
	}
	if rows != nil {
		rows.Close()
	}

	data := map[string]interface{}{
		"User":   user,
		"Groups": groups,
	}
	render(w, "teacher_dashboard", data)
}

// список пар конкретной группы для препода
func groupJournalsHandler(w http.ResponseWriter, r *http.Request) {
	c, err := r.Cookie("user_id")
	if err != nil {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	uid, _ := strconv.Atoi(c.Value)

	var role string
	err = db.QueryRow(`SELECT COALESCE(role,'starosta') FROM users WHERE id=$1`, uid).
		Scan(&role)
	if err != nil || role != "teacher" {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	groupID, _ := strconv.Atoi(r.URL.Query().Get("group"))
	if groupID == 0 {
		http.Error(w, "bad group id", http.StatusBadRequest)
		return
	}

	var groupName string
	if err := db.QueryRow(`SELECT name FROM groups WHERE id=$1`, groupID).
		Scan(&groupName); err != nil {
		http.Error(w, "group not found", http.StatusNotFound)
		return
	}

	rows, _ := db.Query(`
		SELECT id, day_of_week, subject_name, start_time
		FROM schedule
		WHERE group_id = $1
		ORDER BY day_of_week, start_time
	`, groupID)
	var lessons []GroupScheduleRow
	if rows != nil {
		defer rows.Close()
		for rows.Next() {
			var r GroupScheduleRow
			rows.Scan(&r.ID, &r.Day, &r.Subject, &r.Time)
			lessons = append(lessons, r)
		}
	}

	data := map[string]interface{}{
		"GroupID":   groupID,
		"GroupName": groupName,
		"Lessons":   lessons,
	}
	render(w, "teacher_group_journals", data)
}

// кабинет админа: только большая таблица пользователей
func adminPanelHandler(w http.ResponseWriter, user User) {
	urows, _ := db.Query(`
		SELECT u.id, u.username, COALESCE(u.role,'starosta'),
		       COALESCE(g.name,'—')
		FROM users u
		LEFT JOIN groups g ON u.group_id = g.id
		ORDER BY u.id
	`)
	var users []AdminUserRow
	for urows != nil && urows.Next() {
		var r AdminUserRow
		urows.Scan(&r.ID, &r.Username, &r.Role, &r.Group)
		users = append(users, r)
	}
	if urows != nil {
		urows.Close()
	}

	data := map[string]interface{}{
		"User":  user,
		"Users": users,
	}
	render(w, "admin_dashboard", data)
}

// журнал (шахматка)
func journalHandler(w http.ResponseWriter, r *http.Request) {
	subjectID, _ := strconv.Atoi(r.URL.Query().Get("id"))
	if subjectID == 0 {
		http.Error(w, "нет id предмета", http.StatusBadRequest)
		return
	}

	role := "guest"
	var userGroupID int
	if c, err := r.Cookie("user_id"); err == nil {
		if uid, err := strconv.Atoi(c.Value); err == nil {
			_ = db.QueryRow(`SELECT COALESCE(role,'starosta'), COALESCE(group_id,0)
			                 FROM users WHERE id=$1`, uid).
				Scan(&role, &userGroupID)
		}
	}

	var subjName, wType string
	var groupID int
	err := db.QueryRow(`
		SELECT subject_name, week_type, group_id
		FROM schedule
		WHERE id = $1
	`, subjectID).Scan(&subjName, &wType, &groupID)
	if err != nil {
		http.Error(w, "предмет не найден", http.StatusNotFound)
		return
	}

	// староста может смотреть только свою группу
	if role == "starosta" && userGroupID != groupID {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	rows, _ := db.Query(`
		SELECT id, full_name
		FROM students
		WHERE group_id = $1
		ORDER BY full_name
	`, groupID)
	var jrows []JournalRow
	if rows != nil {
		defer rows.Close()
		for rows.Next() {
			var r JournalRow
			r.Marks = make(map[int]bool)
			rows.Scan(&r.StudentID, &r.StudentName)
			jrows = append(jrows, r)
		}
	}

	marks, _ := db.Query(`
		SELECT student_id, week_number
		FROM attendance
		WHERE schedule_id = $1 AND status = 'present'
	`, subjectID)
	if marks != nil {
		defer marks.Close()
		for marks.Next() {
			var sid, wn int
			marks.Scan(&sid, &wn)
			for i := range jrows {
				if jrows[i].StudentID == sid {
					jrows[i].Marks[wn] = true
				}
			}
		}
	}

	var weeks []int
	for i := 1; i <= 17; i++ {
		if getWeekType(i) == wType {
			weeks = append(weeks, i)
		}
	}

	data := map[string]interface{}{
		"SubjectName": subjName,
		"SubjectID":   subjectID,
		"WeekType":    wType,
		"Weeks":       weeks,
		"Rows":        jrows,
		"Role":        role,
	}
	render(w, "journal", data)
}

// ajax: отмечать посещаемость (только староста своей группы)
func apiMarkHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	c, err := r.Cookie("user_id")
	if err != nil {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	uid, _ := strconv.Atoi(c.Value)

	var role string
	var userGroupID int
	err = db.QueryRow(`SELECT COALESCE(role,'starosta'), COALESCE(group_id,0)
	                   FROM users WHERE id=$1`, uid).
		Scan(&role, &userGroupID)
	if err != nil {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	if role != "starosta" {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	var req struct {
		StudentID  int
		ScheduleID int
		Week       int
		Action     string
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad json", http.StatusBadRequest)
		return
	}

	var schedGroupID int
	if err := db.QueryRow(`SELECT group_id FROM schedule WHERE id=$1`, req.ScheduleID).
		Scan(&schedGroupID); err != nil || schedGroupID != userGroupID {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	if req.Action == "add" {
		_, _ = db.Exec(`
			INSERT INTO attendance (student_id, schedule_id, week_number, status)
			VALUES ($1,$2,$3,'present')
			ON CONFLICT (student_id, schedule_id, week_number)
			DO UPDATE SET status='present'
		`, req.StudentID, req.ScheduleID, req.Week)
	} else {
		_, _ = db.Exec(`
			DELETE FROM attendance
			WHERE student_id=$1 AND schedule_id=$2 AND week_number=$3
		`, req.StudentID, req.ScheduleID, req.Week)
	}
	w.Write([]byte("OK"))
}

// удаление пользователя админом
func adminDeleteUserHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	idStr := r.FormValue("id")
	id, err := strconv.Atoi(idStr)
	if err != nil || id <= 0 {
		http.Error(w, "bad id", http.StatusBadRequest)
		return
	}

	if c, err := r.Cookie("user_id"); err == nil {
		if selfID, _ := strconv.Atoi(c.Value); selfID == id {
			http.Error(w, "нельзя удалить свой аккаунт", http.StatusBadRequest)
			return
		}
	}

	_, err = db.Exec("DELETE FROM users WHERE id=$1", id)
	if err != nil {
		http.Error(w, "db error", http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

// регистрация
func registerHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodPost {
		username := r.FormValue("username")
		password := r.FormValue("password")
		role := r.FormValue("role")

		if role != "starosta" && role != "teacher" && role != "admin" {
			role = "starosta"
		}

		var groupID interface{} = nil
		if role == "starosta" {
			if gid, err := strconv.Atoi(r.FormValue("group_id")); err == nil {
				groupID = gid
			}
		}

		hash, _ := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)

		_, err := db.Exec(
			"INSERT INTO users (username, password_hash, role, group_id) VALUES ($1,$2,$3,$4)",
			username, string(hash), role, groupID,
		)
		if err == nil {
			http.Redirect(w, r, "/login", http.StatusSeeOther)
			return
		}
		render(w, "register", "Ошибка регистрации (логин занят?)")
		return
	}
	render(w, "register", nil)
}

// логин
func loginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodPost {
		u := r.FormValue("username")
		p := r.FormValue("password")

		var id int
		var hash string
		err := db.QueryRow("SELECT id, password_hash FROM users WHERE username=$1", u).
			Scan(&id, &hash)
		if err == nil && bcrypt.CompareHashAndPassword([]byte(hash), []byte(p)) == nil {
			http.SetCookie(w, &http.Cookie{
				Name:  "user_id",
				Value: strconv.Itoa(id),
				Path:  "/",
			})
			http.Redirect(w, r, "/", http.StatusSeeOther)
			return
		}
		render(w, "login", "Неверный логин или пароль")
		return
	}
	render(w, "login", nil)
}

func main() {
	var err error
	connStr := fmt.Sprintf(
		"postgres://%s:%s@localhost:5432/%s?sslmode=disable",
		DB_USER, DB_PASSWORD, DB_NAME,
	)
	db, err = sql.Open("pgx", connStr)
	if err != nil {
		log.Fatal(err)
	}
	if err = db.Ping(); err != nil {
		log.Fatal("нет подключения к БД:", err)
	}

	// статика (логотип и пр.)
	fs := http.FileServer(http.Dir("static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	http.HandleFunc("/", indexHandler)
	http.HandleFunc("/journal", journalHandler)
	http.HandleFunc("/group-journals", groupJournalsHandler)
	http.HandleFunc("/api/mark", apiMarkHandler)
	http.HandleFunc("/login", loginHandler)
	http.HandleFunc("/register", registerHandler)
	http.HandleFunc("/admin/delete-user", adminDeleteUserHandler)
	http.HandleFunc("/logout", func(w http.ResponseWriter, r *http.Request) {
		http.SetCookie(w, &http.Cookie{
			Name:   "user_id",
			MaxAge: -1,
			Path:   "/",
		})
		http.Redirect(w, r, "/login", http.StatusSeeOther)
	})

	log.Println("Сервер запущен: http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

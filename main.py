from operator import itemgetter

class House:
    def __init__(self, id, address, area, floors, street_id):
        self.id = id
        self.address = address
        self.area = area 
        self.floors = floors
        self.street_id = street_id

class Street:
    def __init__(self, id, name, district):
        self.id = id
        self.name = name
        self.district = district

class HouseStreet:
    def __init__(self, street_id, house_id):
        self.street_id = street_id
        self.house_id = house_id


streets = [
    Street(1, "Ленинский проспект", "Центральный"),
    Street(2, "улица Гагарина", "Северный"),
    Street(3, "отдел строительства", "Западный"),
    Street(4, "Проспект Мира", "Восточный"),
    Street(5, "отдел архитектуры", "Южный"),
    Street(6, "Арбат", "Центральный"),
]

houses = [
    House(1, "Ленинский пр-т, 10", 1200, 5, 1),
    House(2, "Ленинский пр-т, 12", 800, 3, 1),
    House(3, "ул. Гагарина, 5", 1500, 9, 2),
    House(4, "ул. Гагарина, 7", 600, 2, 2),
    House(5, "отдел строительства, 1", 2000, 12, 3),
    House(6, "Проспект Мира, 15", 900, 4, 4),
    House(7, "отдел архитектуры, 3", 1100, 6, 5),
    House(8, "Арбат, 25", 750, 3, 6),
]

houses_streets = [
    HouseStreet(1, 1),
    HouseStreet(1, 2),
    HouseStreet(2, 3),
    HouseStreet(2, 4),
    HouseStreet(3, 5),
    HouseStreet(4, 6),
    HouseStreet(5, 7),
    HouseStreet(6, 8),
    HouseStreet(3, 1),  
    HouseStreet(5, 3),
]

def main():
    
    one_to_many = [(h.address, h.area, h.floors, s.name)
                   for s in streets
                   for h in houses
                   if h.street_id == s.id]
    
    many_to_many_temp = [(s.name, hs.street_id, hs.house_id)
                         for s in streets
                         for hs in houses_streets
                         if s.id == hs.street_id]
    
    many_to_many = [(h.address, h.area, h.floors, street_name)
                    for street_name, street_id, house_id in many_to_many_temp
                    for h in houses if h.id == house_id]

    print('Задание А1')

    res_a1 = sorted(one_to_many, key=itemgetter(3))
    for item in res_a1:
        print(f"{item[3]}: {item[0]} (площадь: {item[1]} кв.м, этажей: {item[2]})")

    print('\nЗадание А2')
    
    res_a2_unsorted = []
    for s in streets:
        s_houses = list(filter(lambda i: i[3] == s.name, one_to_many))
        if len(s_houses) > 0:
            s_areas = [area for _, area, _, _ in s_houses]
            s_total_area = sum(s_areas)
            res_a2_unsorted.append((s.name, s_total_area))
    
   
    res_a2 = sorted(res_a2_unsorted, key=itemgetter(1), reverse=True)
    print("Улицы с суммарной площадью домов:")
    for street, total_area in res_a2:
        print(f"{street}: {total_area} кв.м")

    print('\nЗадание А3')

    res_a3 = {}
    for s in streets:
        if 'отдел' in s.name:
            s_houses = list(filter(lambda i: i[3] == s.name, many_to_many))
            s_houses_addresses = [x for x, *_, _ in s_houses]
            res_a3[s.name] = s_houses_addresses
    
    print("Улицы с 'отдел' в названии и дома на них:")
    for street, houses_list in res_a3.items():
        print(f"{street}: {houses_list}")

if __name__ == '__main__':
    main()
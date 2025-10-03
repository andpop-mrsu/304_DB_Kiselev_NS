import csv
from pathlib import Path


def read_dataset_files():
    dataset_path = Path('dataset')
    files = {}

    for file_path in dataset_path.glob('*.*'):
        if file_path.suffix.lower() in ['.csv', '.txt']:
            with open(file_path, 'r', encoding='utf-8') as f:
                if file_path.suffix.lower() == '.txt':
                    first_line = f.readline().strip()
                    f.seek(0)

                    if '|' in first_line:
                        field_count = len(first_line.split('|'))
                        if field_count == 6:
                            fieldnames = ['id', 'name', 'email', 'gender', 'register_date', 'occupation']
                        elif field_count == 4:
                            fieldnames = ['userId', 'movieId', 'rating', 'timestamp']
                        elif field_count == 3:
                            fieldnames = ['userId', 'movieId', 'tag']
                        else:
                            fieldnames = [f'field_{i}' for i in range(field_count)]

                        reader = csv.DictReader(f, delimiter='|', fieldnames=fieldnames)
                        files[file_path.stem] = list(reader)
                    else:
                        reader = csv.DictReader(f)
                        files[file_path.stem] = list(reader)
                else:
                    reader = csv.DictReader(f)
                    files[file_path.stem] = list(reader)

    return files


def generate_create_table_sql():
    sql_commands = []

    sql_commands.extend([
        "DROP TABLE IF EXISTS movies;",
        "DROP TABLE IF EXISTS ratings;",
        "DROP TABLE IF EXISTS tags;",
        "DROP TABLE IF EXISTS users;"
    ])

    sql_commands.extend([
        """CREATE TABLE movies (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            year INTEGER,
            genres TEXT
        );""",

        """CREATE TABLE ratings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            movie_id INTEGER NOT NULL,
            rating REAL NOT NULL,
            timestamp INTEGER NOT NULL,
            FOREIGN KEY (movie_id) REFERENCES movies(id),
            FOREIGN KEY (user_id) REFERENCES users(id)
        );""",

        """CREATE TABLE tags (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            movie_id INTEGER NOT NULL,
            tag TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            FOREIGN KEY (movie_id) REFERENCES movies(id),
            FOREIGN KEY (user_id) REFERENCES users(id)
        );""",

        """CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            gender TEXT NOT NULL,
            register_date TEXT NOT NULL,
            occupation TEXT NOT NULL
        );"""
    ])

    return sql_commands


def escape_sql_value(value):
    if value is None:
        return 'NULL'
    return str(value).replace("'", "''")


def generate_insert_sql(data_files):
    insert_commands = []

    if 'users' in data_files:
        for user in data_files['users']:
            insert_commands.append(
                f"INSERT INTO users (id, name, email, gender, register_date, occupation) "
                f"VALUES ({user['id']}, '{escape_sql_value(user['name'])}', "
                f"'{escape_sql_value(user['email'])}', '{escape_sql_value(user['gender'])}', "
                f"'{escape_sql_value(user['register_date'])}', '{escape_sql_value(user['occupation'])}');"
            )

    if 'movies' in data_files:
        for movie in data_files['movies']:
            title = escape_sql_value(movie['title'])
            year = None
            clean_title = title

            if '(' in title and ')' in title:
                try:
                    year_part = title.split('(')[-1].split(')')[0]
                    if len(year_part) == 4 and year_part.isdigit():
                        year = int(year_part)
                        year_pattern = f"({year_part})"
                        clean_title = title.replace(year_pattern, "").strip()
                        clean_title = ' '.join(clean_title.split())
                except:
                    year = None
                    clean_title = title

            genres = escape_sql_value(movie.get('genres', ''))

            year_sql = str(year) if year is not None else 'NULL'
            insert_commands.append(
                f"INSERT INTO movies (id, title, year, genres) "
                f"VALUES ({movie['movieId']}, '{clean_title}', {year_sql}, '{genres}');"
            )

    if 'ratings' in data_files:
        for rating in data_files['ratings']:
            insert_commands.append(
                f"INSERT INTO ratings (user_id, movie_id, rating, timestamp) "
                f"VALUES ({rating['userId']}, {rating['movieId']}, {rating['rating']}, {rating['timestamp']});"
            )

    if 'tags' in data_files:
        for tag in data_files['tags']:
            tag_text = escape_sql_value(tag['tag'])
            insert_commands.append(
                f"INSERT INTO tags (user_id, movie_id, tag, timestamp) "
                f"VALUES ({tag['userId']}, {tag['movieId']}, '{tag_text}', {tag['timestamp']});"
            )

    return insert_commands


def main():
    data_files = read_dataset_files()

    if not data_files:
        return

    sql_commands = []

    sql_commands.extend(generate_create_table_sql())

    sql_commands.extend(generate_insert_sql(data_files))

    with open('db_init.sql', 'w', encoding='utf-8') as f:
        for command in sql_commands:
            f.write(command + '\n')


if __name__ == "__main__":
    main()
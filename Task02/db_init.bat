# !/bin/bash
echo make_db_init.py start execution
python make_db_init.py
echo make_db_init.py executed. Begin movies_rating.db < db_init.sql transfer
sqlite3 movies_rating.db < db_init.sql
echo Transfer completed
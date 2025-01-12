"""
Django command to wait for the database to be available
"""

import time
from psycopg2 import OperationalError as Psycopg2OpError
from django.db.utils import OperationalError
from django.core.management.base import BaseCommand


class Command (BaseCommand):
    """Django command to pause execution until database is available"""

    def handle(self, *args, **options):
        """Entry point for command"""
        self.stdout.write('Waiting for database...')
        db_up = False
        time_in_sec = 0
        while db_up is False:
            try:
                # self.check is a built-in method available to custom
                # Django management commands. It performs a variety
                # of system checks to ensure the Django project is properly
                # configured and functioning. It is usually used to
                # validate settings, database connections, and other
                # project-specific configurations.
                # When calling self.check(databases=['default']), it
                # specifically checks the connection to the database
                # configured under the default key in the DATABASES setting.
                self.check(databases=['default'])
                db_up = True
            except (Psycopg2OpError, OperationalError):
                time_in_sec += 1
                self.stdout.write(f"Database unavailable, \
                    waiting {time_in_sec} second(s)...")
                time.sleep(1)

        self.stdout.write(self.style.SUCCESS('Database available'))

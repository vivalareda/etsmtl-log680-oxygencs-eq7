from enum import Enum
import os
import psycopg2


class Table(Enum):
    HVAC = "hvac"
    HVAC_EVENTS = "hvac_events"


class Crud:
    _instance = None
    connection = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(Crud, cls).__new__(cls)
            cls._instance.init_singleton()
        return cls._instance

    def init_singleton(self):
        self.DB_NAME = os.getenv('DB_NAME')
        self.DB_USER = os.getenv('DB_USER')
        self.DB_HOST = os.getenv('DB_HOST')
        self.DB_PASS = os.getenv('DB_PASS')

    def connect(self):
        self.connection = psycopg2.connect(host=os.getenv('DB_HOST'),
                            database=os.getenv('DB_NAME'),
                            user=os.getenv('DB_USER'),
                            password=os.getenv('DB_PASS'))

    def insert_metric(self, table: Table, metric_name: str, metric_value: str):
        try:
            cursor = self.connection.cursor()

            if table == Table.HVAC:
                insert_query = (
                    "INSERT INTO hvac (timestamp, value) VALUES (%s, %s)"
                )
            
            elif table == Table.HVAC_EVENTS:
                insert_query = (
                    "INSERT INTO hvac_events (timestamp, value) VALUES (%s, %s)"
                )

            cursor.execute(insert_query, (metric_name, metric_value))

            # Insert a new metric
            self.connection.commit()
            print("metric inserted successfully!")

        except Exception as e:
            print(f"Error creating metric: {e}")

        finally:
            cursor.close()

    def read_metrics(self, table: Table):
        try:
            cursor = self.connection.cursor()

            if table == Table.HVAC:
                select_query = "SELECT * FROM hvac"

            elif table == Table.HVAC_EVENTS:
                select_query = "SELECT * FROM hvac_events"


            # Select all metrics
            cursor.execute(select_query)

            metrics = cursor.fetchall()
            for metric in metrics:
                print(metric)

        except Exception as e:
            print(f"Error reading metrics: {e}")

        finally:
            cursor.close()

    def update_metric(self, table: Table, metric_id, new_value):
        try:
            cursor = self.connection.cursor()
            
            if table == Table.HVAC:
                update_query = "UPDATE hvac SET value = %s WHERE id = %s"
                
            elif table == Table.HVAC_EVENTS:
                update_query = "UPDATE hvac_events SET value = %s WHERE id = %s"

            # Update a metric by metric_id
            cursor.execute(update_query, (new_value, metric_id))
            self.connection.commit()

            print("Metric updated successfully!")

        except Exception as e:
            print(f"Error updating metric: {e}")

        finally:
            cursor.close()

    def delete_metric(self, table: Table, metric_id):
        try:
            cursor = self.connection.cursor()

            if table == Table.HVAC:
                delete_query = "DELETE FROM hvac WHERE id = %s"
                
            elif table == Table.HVAC_EVENTS:
                delete_query = "DELETE FROM hvac_events WHERE id = %s"
    
            cursor.execute(delete_query, (metric_id,))
            self.connection.commit()

            print("Metric deleted successfully!")

        except Exception as e:
            print(f"Error deleting metric: {e}")

        finally:
            cursor.close()

    def close_connection(self):
        self.connection.close()
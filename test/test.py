import unittest
from unittest.mock import patch, MagicMock
from src.main import App  # Ensure you replace 'your_module_name' with the actual name of your Python file without the .py extension

class TestApp(unittest.TestCase):

    @patch('os.getenv')
    def test_init_with_all_env_vars(self, mock_getenv):
        """Test initialization with all required environment variables present."""
        mock_getenv.side_effect = lambda x, default=None: {'HOST': 'test_host', 'TOKEN': 'test_token', 'DATABASE': 'test_db', 'TICKETS': '1', 'T_MAX': '25', 'T_MIN': '18'}.get(x, default)
        app = App()
        self.assertEqual(app.HOST, 'test_host')
        self.assertEqual(app.TOKEN, 'test_token')
        self.assertEqual(app.TICKETS, '1')
        self.assertEqual(app.T_MAX, '25')
        self.assertEqual(app.T_MIN, '18')

    @patch('os.getenv')
    def test_init_missing_env_vars(self, mock_getenv):
        """Test initialization fails when required environment variables are missing."""
        mock_getenv.return_value = None
        with self.assertRaises(EnvironmentError) as context:
            App()
        self.assertIn("Missing environment variables", str(context.exception))

    @patch('your_module_name.HubConnectionBuilder')
    def test_setup_sensor_hub(self, mock_hub_connection_builder):
        """Test sensor hub setup."""
        with patch.dict('os.environ', {'HOST': 'dummy_host', 'TOKEN': 'dummy_token'}):
            app = App()
            app.setup_sensor_hub()
            mock_hub_connection_builder.assert_called()

    @patch('your_module_name.requests.get')
    def test_send_action_to_hvac(self, mock_get):
        """Test sending action to the HVAC system."""
        mock_response = MagicMock()
        mock_response.text = json.dumps({"status": "success"})
        mock_get.return_value = mock_response

        with patch.dict('os.environ', {'HOST': 'http://localhost', 'TOKEN': 'dummy_token', 'TICKETS': '1'}):
            app = App()
            app.send_action_to_hvac("TurnOnAc")
            mock_get.assert_called_with('http://localhost/api/hvac/dummy_token/TurnOnAc/1')

    def test_take_action(self):
        """Test action decision logic based on temperature."""
        with patch.dict('os.environ', {'T_MAX': '25', 'T_MIN': '18'}):
            with patch.object(App, 'send_action_to_hvac') as mock_send_action:
                app = App()
                app.take_action(26)
                mock_send_action.assert_called_with("TurnOnAc")
                app.take_action(17)
                mock_send_action.assert_called_with("TurnOnHeater")

# Make sure to exclude database-related tests as requested.

if __name__ == '__main__':
    unittest.main()

import unittest
from unittest.mock import patch, Mock
from src.main import App
import os

class TestApp(unittest.TestCase):

    def setUp(self):
        """Set up test environment for each test."""
        with patch.dict(os.environ, {'HOST': 'http://example.com', 'TOKEN': 'dummy_token', 'TICKS': '1', 'T_MAX': '25', 'T_MIN': '18', 'DATABASE': 'test_db'}):
            self.app = App()

    def test_initialization_with_required_environment_variables(self):
        """Test App initializes correctly with all required environment variables."""
        self.assertEqual(self.app.HOST, 'http://example.com')
        self.assertEqual(self.app.TOKEN, 'dummy_token')
        self.assertEqual(self.app.TICKS, '1')
        self.assertEqual(self.app.T_MAX, '25')
        self.assertEqual(self.app.T_MIN, '18')

    @patch('src.main.HubConnectionBuilder')  # Adjusted path
    def test_setup_sensor_hub(self, mock_hub_connection_builder):
        """Test sensor hub setup."""
        self.app.setup_sensor_hub()
        mock_hub_connection_builder.return_value.with_url.assert_called_once_with(f"{self.app.HOST}/SensorHub?token={self.app.TOKEN}")

    @patch('src.main.App.send_action_to_hvac')  # Adjusted path
    def test_take_action_turn_on_ac(self, mock_send_action):
        """Test AC turns on when temperature is above T_MAX."""
        self.app.take_action(float(self.app.T_MAX) + 1)
        mock_send_action.assert_called_once_with('TurnOnAc')

    @patch('src.main.App.send_action_to_hvac')  # Adjusted path
    def test_take_action_turn_on_heater(self, mock_send_action):
        """Test Heater turns on when temperature is below T_MIN."""
        self.app.take_action(float(self.app.T_MIN) - 1)
        mock_send_action.assert_called_once_with('TurnOnHeater')

    @patch('src.main.requests.get')  # Adjusted path
    def test_send_action_to_hvac(self, mock_get):
        """Test sending action to HVAC service."""
        mock_get.return_value.text = '{"result": "success"}'
        self.app.send_action_to_hvac('TurnOnAc')
        mock_get.assert_called_once_with(f"{self.app.HOST}/api/hvac/{self.app.TOKEN}/TurnOnAc/1")

if __name__ == '__main__':
    unittest.main()

from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By

def login(selenium, device_user, device_password):
    selenium.open_app()
    selenium.screenshot('index')

    selenium.find_by(By.XPATH, "//input[@name='username')]")
    username.send_keys(device_user)
    selenium.find_by(By.XPATH, "//input[@name='password')]")
    password.send_keys(device_password)
    selenium.screenshot('login-credentials')
    password.send_keys(Keys.RETURN)
    selenium.screenshot('login-submitted')

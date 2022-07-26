from selenium.webdriver.common.keys import Keys

def login(selenium, device_user, device_password):
    selenium.open_app()
    selenium.screenshot('index')
    username = selenium.find_by_id('username')
    username.send_keys(device_user)
    password = selenium.find_by_id('password')
    password.send_keys(device_password)
    selenium.screenshot('login-credentials')
    password.send_keys(Keys.RETURN)
    selenium.screenshot('login-submitted')
password)
    selenium.screenshot('login-credentials')
    password.send_keys(Keys.RETURN)
    selenium.screenshot('login-submitted')

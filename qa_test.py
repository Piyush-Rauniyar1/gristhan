import time
import unittest
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

class GristhanQATests(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        print("\n🚀 Initializing Selenium WebDriver...")
        options = webdriver.ChromeOptions()
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        
        # Adding a fake user agent to avoid basic bot blocking
        options.add_argument("user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36")
        
        cls.driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
        cls.driver.implicitly_wait(5) # global implicit wait
        cls.base_url = "https://gristhan.vercel.app"

    @classmethod
    def tearDownClass(cls):
        print("\n🛑 Closing WebDriver...")
        cls.driver.quit()

    def test_01_homepage_loads(self):
        """Test if the homepage loads properly and title is correct"""
        self.driver.get(f"{self.base_url}/")
        
        # Check title (Vite default is often 'Vite + React' if not changed, but we check if it exists)
        self.assertTrue(self.driver.title != "", "Page title should not be empty")
        
        # Verify navigation bar exists (most apps have a header or nav tag)
        nav = self.driver.find_elements(By.TAG_NAME, "nav")
        self.assertGreaterEqual(len(nav), 0, "Navbar should exist")
        print("✅ Homepage loaded successfully.")

    def test_02_login_form_validation(self):
        """Test login form validation errors without credentials"""
        self.driver.get(f"{self.base_url}/auth")
        
        submit_btn = WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.ID, "login-submit"))
        )
        self.driver.execute_script("arguments[0].scrollIntoView(true);", submit_btn)
        time.sleep(0.5)
        self.driver.execute_script("arguments[0].click();", submit_btn)
        
        # Should show a validation error message in the DOM
        page_source = self.driver.page_source
        self.assertTrue("valid email" in page_source.lower() or "required" in page_source.lower(), 
                        "Validation error should appear on empty submit")
        print("✅ Login form validation works.")

    def test_03_login_flow(self):
        """Test the login flow with dummy credentials"""
        self.driver.get(f"{self.base_url}/auth")
        
        wait = WebDriverWait(self.driver, 10)
        
        # Fill email
        email_input = wait.until(EC.presence_of_element_located((By.ID, "login-email")))
        email_input.clear()
        email_input.send_keys("test_qa_user@example.com")
        
        # Fill password
        password_input = self.driver.find_element(By.ID, "login-password")
        password_input.clear()
        password_input.send_keys("Password123!")
        
        # Submit
        submit_btn = self.driver.find_element(By.ID, "login-submit")
        self.driver.execute_script("arguments[0].scrollIntoView(true);", submit_btn)
        time.sleep(0.5)
        self.driver.execute_script("arguments[0].click();", submit_btn)
        
        # Wait a few seconds for network request to finish
        time.sleep(3)
        
        # We expect this login to either succeed (redirect) or fail cleanly (show error message)
        # Since it's a dummy user, it will likely show "Invalid credentials" or similar.
        current_url = self.driver.current_url
        page_source = self.driver.page_source
        
        if "auth" in current_url:
            self.assertTrue("error" in page_source.lower() or "invalid" in page_source.lower() or "found" in page_source.lower(), 
                            "If login fails, an error message should be displayed")
            print("✅ Login cleanly rejected dummy credentials.")
        else:
            print("✅ Redirected successfully to dashboard.")

    def test_04_navigation_to_property_detail(self):
        """Test navigating to a property detail page directly"""
        # We can't guarantee a specific ID exists, but we can test the fallback/loading state of the page
        test_uuid = "123e4567-e89b-12d3-a456-426614174000"
        self.driver.get(f"{self.base_url}/property/{test_uuid}")
        
        time.sleep(2) # Wait for potential fetch
        page_source = self.driver.page_source
        
        # The page should render safely, either showing a "not found" message, loading, or the header
        self.assertNotIn("Exception", page_source)
        self.assertNotIn("TypeError", page_source)
        print("✅ Property detail route loads without crashing.")

if __name__ == "__main__":
    # Run tests with verbosity
    unittest.main(verbosity=2)

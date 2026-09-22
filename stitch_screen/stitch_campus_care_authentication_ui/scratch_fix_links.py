import os
import re

BASE_DIR = r"d:\Campus Complaint Management\stitch_screen\stitch_campus_care_authentication_ui"

# Let's inspect each desktop file and replace dead '#' hrefs with appropriate functional routes
def update_inpage_action_links():
    # 1. Screen 1 Auth
    s1_desktop = os.path.join(BASE_DIR, "campus_care_desktop_authentication", "code.html")
    s1_mobile = os.path.join(BASE_DIR, "campus_care_mobile_authentication", "code.html")
    
    if os.path.exists(s1_desktop):
        with open(s1_desktop, "r", encoding="utf-8") as f:
            c = f.read()
        # Ensure form or button submits to screen 2
        c = re.sub(r'action="[^"]*"', 'action="../campus_care_institution_workspace_switcher_desktop/code.html"', c)
        c = re.sub(r'href="#"', 'href="../campus_care_institution_workspace_switcher_desktop/code.html"', c)
        with open(s1_desktop, "w", encoding="utf-8") as f:
            f.write(c)

    if os.path.exists(s1_mobile):
        with open(s1_mobile, "r", encoding="utf-8") as f:
            c = f.read()
        c = re.sub(r'action="[^"]*"', 'action="../campus_care_institution_workspace_switcher_mobile/code.html"', c)
        c = re.sub(r'href="#"', 'href="../campus_care_institution_workspace_switcher_mobile/code.html"', c)
        with open(s1_mobile, "w", encoding="utf-8") as f:
            f.write(c)

    # 2. Screen 2 Switcher
    s2_desktop = os.path.join(BASE_DIR, "campus_care_institution_workspace_switcher_desktop", "code.html")
    s2_mobile = os.path.join(BASE_DIR, "campus_care_institution_workspace_switcher_mobile", "code.html")
    if os.path.exists(s2_desktop):
        with open(s2_desktop, "r", encoding="utf-8") as f:
            c = f.read()
        c = c.replace('href="#"', 'href="../campus_care_complaints_dashboard_desktop/code.html"')
        with open(s2_desktop, "w", encoding="utf-8") as f:
            f.write(c)
    if os.path.exists(s2_mobile):
        with open(s2_mobile, "r", encoding="utf-8") as f:
            c = f.read()
        c = c.replace('href="#"', 'href="../campus_care_complaints_dashboard_mobile/code.html"')
        with open(s2_mobile, "w", encoding="utf-8") as f:
            f.write(c)

    # 3. Screen 3 Dashboard
    s3_desktop = os.path.join(BASE_DIR, "campus_care_complaints_dashboard_desktop", "code.html")
    s3_mobile = os.path.join(BASE_DIR, "campus_care_complaints_dashboard_mobile", "code.html")
    if os.path.exists(s3_desktop):
        with open(s3_desktop, "r", encoding="utf-8") as f:
            c = f.read()
        c = c.replace('href="#"', 'href="../campus_care_issue_detail_lifecycle_resolution_tracker_desktop/code.html"')
        with open(s3_desktop, "w", encoding="utf-8") as f:
            f.write(c)
    if os.path.exists(s3_mobile):
        with open(s3_mobile, "r", encoding="utf-8") as f:
            c = f.read()
        c = c.replace('href="#"', 'href="../campus_care_issue_detail_lifecycle_resolution_tracker_mobile/code.html"')
        with open(s3_mobile, "w", encoding="utf-8") as f:
            f.write(c)

    print("Updated in-page interactive action links.")

if __name__ == "__main__":
    update_inpage_action_links()

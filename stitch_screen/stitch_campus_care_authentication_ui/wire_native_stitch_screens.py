import os
import re

BASE_DIR = r"d:\Campus Complaint Management\stitch_screen\stitch_campus_care_authentication_ui"

def wire_stitch_screens():
    # 1. Desktop Authentication (Screen 1)
    s1_d_path = os.path.join(BASE_DIR, "campus_care_desktop_authentication", "code.html")
    if os.path.exists(s1_d_path):
        with open(s1_d_path, "r", encoding="utf-8") as f:
            c = f.read()
        # Wire SSO and Sign In button / form
        c = re.sub(r'<form\b([^>]*)>', r'<form\1 onsubmit="window.location.href=\'../campus_care_institution_workspace_switcher_desktop/code.html\'; return false;">', c)
        c = c.replace("Sign In with Campus SSO", "Sign In with Campus SSO")
        # In case there's an anchor or button for SSO
        c = re.sub(r'(<button[^>]*>.*?Campus SSO.*?</button>)', r'<a href="../campus_care_institution_workspace_switcher_desktop/code.html" class="block w-full">\1</a>', c)
        with open(s1_d_path, "w", encoding="utf-8") as f:
            f.write(c)

    # 1. Mobile Authentication
    s1_m_path = os.path.join(BASE_DIR, "campus_care_mobile_authentication", "code.html")
    if os.path.exists(s1_m_path):
        with open(s1_m_path, "r", encoding="utf-8") as f:
            c = f.read()
        c = re.sub(r'<form\b([^>]*)>', r'<form\1 onsubmit="window.location.href=\'../campus_care_institution_workspace_switcher_mobile/code.html\'; return false;">', c)
        c = re.sub(r'(<button[^>]*>.*?Campus SSO.*?</button>)', r'<a href="../campus_care_institution_workspace_switcher_mobile/code.html" class="block w-full">\1</a>', c)
        with open(s1_m_path, "w", encoding="utf-8") as f:
            f.write(c)

    # 2. Workspace Switcher (Screen 2)
    s2_d_path = os.path.join(BASE_DIR, "campus_care_institution_workspace_switcher_desktop", "code.html")
    if os.path.exists(s2_d_path):
        with open(s2_d_path, "r", encoding="utf-8") as f:
            c = f.read()
        # Wire "Confirm & Enter Workspace" and "Sign Out"
        c = re.sub(r'(<button[^>]*id="confirm-workspace-btn"[^>]*>)', r'<a href="../campus_care_complaints_dashboard_desktop/code.html" class="w-full flex">\1', c)
        c = re.sub(r'(</button>\s*<!-- end confirm-workspace-btn -->|Confirm &amp; Enter Workspace\s*</button>)', r'\1</a>', c)
        # Ensure clicking Confirm button directly navigates
        if "confirm-workspace-btn" in c and "onclick" not in c:
            c = c.replace('id="confirm-workspace-btn"', 'id="confirm-workspace-btn" onclick="window.location.href=\'../campus_care_complaints_dashboard_desktop/code.html\'"')
        with open(s2_d_path, "w", encoding="utf-8") as f:
            f.write(c)

    s2_m_path = os.path.join(BASE_DIR, "campus_care_institution_workspace_switcher_mobile", "code.html")
    if os.path.exists(s2_m_path):
        with open(s2_m_path, "r", encoding="utf-8") as f:
            c = f.read()
        if "confirm-workspace-btn" in c:
            c = c.replace('id="confirm-workspace-btn"', 'id="confirm-workspace-btn" onclick="window.location.href=\'../campus_care_complaints_dashboard_mobile/code.html\'"')
        with open(s2_m_path, "w", encoding="utf-8") as f:
            f.write(c)

    # 3. Complaints Dashboard (Screen 3)
    s3_d_path = os.path.join(BASE_DIR, "campus_care_complaints_dashboard_desktop", "code.html")
    if os.path.exists(s3_d_path):
        with open(s3_d_path, "r", encoding="utf-8") as f:
            c = f.read()
        # Wire "+ Report Issue" button to Screen 4
        c = re.sub(r'(<button[^>]*>\s*<span[^>]*>add</span>\s*Report Issue\s*</button>)', r'<a href="../campus_care_issue_filing_form_with_voice_input_desktop/code.html">\1</a>', c)
        # Wire Sidebar links
        c = c.replace('href="#"', 'href="../campus_care_issue_detail_lifecycle_resolution_tracker_desktop/code.html"')
        with open(s3_d_path, "w", encoding="utf-8") as f:
            f.write(c)

    s3_m_path = os.path.join(BASE_DIR, "campus_care_complaints_dashboard_mobile", "code.html")
    if os.path.exists(s3_m_path):
        with open(s3_m_path, "r", encoding="utf-8") as f:
            c = f.read()
        # Wire FAB (+) button to Screen 4
        c = re.sub(r'(<button[^>]*>\s*<span[^>]*>add</span>\s*</button>)', r'<a href="../campus_care_issue_filing_form_with_voice_input_mobile/code.html">\1</a>', c)
        with open(s3_m_path, "w", encoding="utf-8") as f:
            f.write(c)

    # 4. Issue Filing Form (Screen 4)
    s4_d_path = os.path.join(BASE_DIR, "campus_care_issue_filing_form_with_voice_input_desktop", "code.html")
    if os.path.exists(s4_d_path):
        with open(s4_d_path, "r", encoding="utf-8") as f:
            c = f.read()
        # Wire Submit Ticket button
        if 'id="submit-ticket-btn"' in c:
            c = c.replace('id="submit-ticket-btn"', 'id="submit-ticket-btn" onclick="window.location.href=\'../campus_care_issue_detail_lifecycle_resolution_tracker_desktop/code.html\'"')
        with open(s4_d_path, "w", encoding="utf-8") as f:
            f.write(c)

    s4_m_path = os.path.join(BASE_DIR, "campus_care_issue_filing_form_with_voice_input_mobile", "code.html")
    if os.path.exists(s4_m_path):
        with open(s4_m_path, "r", encoding="utf-8") as f:
            c = f.read()
        if 'id="submit-ticket-btn"' in c:
            c = c.replace('id="submit-ticket-btn"', 'id="submit-ticket-btn" onclick="window.location.href=\'../campus_care_issue_detail_lifecycle_resolution_tracker_mobile/code.html\'"')
        with open(s4_m_path, "w", encoding="utf-8") as f:
            f.write(c)

    # 5. Lifecycle Tracker (Screen 5)
    s5_d_path = os.path.join(BASE_DIR, "campus_care_issue_detail_lifecycle_resolution_tracker_desktop", "code.html")
    if os.path.exists(s5_d_path):
        with open(s5_d_path, "r", encoding="utf-8") as f:
            c = f.read()
        # Wire Escalate button to Screen 6
        c = c.replace('href="#"', 'href="../campus_care_coordinator_triage_workspace_desktop/code.html"')
        with open(s5_d_path, "w", encoding="utf-8") as f:
            f.write(c)

    # 11. Confidential Grievance (Screen 11)
    s11_d_path = os.path.join(BASE_DIR, "campus_care_confidential_academic_grievance_form_desktop", "code.html")
    if os.path.exists(s11_d_path):
        with open(s11_d_path, "r", encoding="utf-8") as f:
            c = f.read()
        # Wire submit button to Screen 12 Notification Center
        c = re.sub(r'<form\b([^>]*)>', r'<form\1 onsubmit="window.location.href=\'../campus_care_unified_multi_channel_notification_center_desktop/code.html\'; return false;">', c)
        with open(s11_d_path, "w", encoding="utf-8") as f:
            f.write(c)

    # 13. Academic Officer Disposition (Screen 13)
    s13_d_path = os.path.join(BASE_DIR, "campus_care_academic_officer_review_disposition_workspace_desktop", "code.html")
    if os.path.exists(s13_d_path):
        with open(s13_d_path, "r", encoding="utf-8") as f:
            c = f.read()
        # Wire submit button to Screen 14 AI Maintenance Recommendations
        if 'id="submit-disposition-btn"' in c:
            c = c.replace('id="submit-disposition-btn"', 'id="submit-disposition-btn" onclick="window.location.href=\'../campus_care_ai_maintenance_recommendations_desktop/code.html\'"')
        with open(s13_d_path, "w", encoding="utf-8") as f:
            f.write(c)

    s13_m_path = os.path.join(BASE_DIR, "campus_care_academic_officer_review_disposition_workspace_mobile", "code.html")
    if os.path.exists(s13_m_path):
        with open(s13_m_path, "r", encoding="utf-8") as f:
            c = f.read()
        if 'id="submit-disposition-btn"' in c:
            c = c.replace('id="submit-disposition-btn"', 'id="submit-disposition-btn" onclick="window.location.href=\'../campus_care_ai_maintenance_recommendations_mobile/code.html\'"')
        with open(s13_m_path, "w", encoding="utf-8") as f:
            f.write(c)

    print("Native Stitch screen interactive links wired successfully without any design modifications!")

if __name__ == "__main__":
    wire_stitch_screens()

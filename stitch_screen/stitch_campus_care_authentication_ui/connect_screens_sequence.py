import os
import re

BASE_DIR = r"d:\Campus Complaint Management\stitch_screen\stitch_campus_care_authentication_ui"

SCREENS = [
    ("campus_care_desktop_authentication", "campus_care_mobile_authentication", "01. Auth & Persona", "Screen 01"),
    ("campus_care_institution_workspace_switcher_desktop", "campus_care_institution_workspace_switcher_mobile", "02. Campus Switcher", "Screen 02"),
    ("campus_care_complaints_dashboard_desktop", "campus_care_complaints_dashboard_mobile", "03. Complaints Dashboard", "Screen 03"),
    ("campus_care_issue_filing_form_with_voice_input_desktop", "campus_care_issue_filing_form_with_voice_input_mobile", "04. Voice & AI Issue Filing", "Screen 04"),
    ("campus_care_issue_detail_lifecycle_resolution_tracker_desktop", "campus_care_issue_detail_lifecycle_resolution_tracker_mobile", "05. Lifecycle Tracker", "Screen 05"),
    ("campus_care_coordinator_triage_workspace_desktop", "campus_care_coordinator_triage_workspace_mobile", "06. Coordinator Triage", "Screen 06"),
    ("campus_care_maintenance_supervisor_sla_risk_radar_desktop", "campus_care_maintenance_supervisor_sla_risk_radar_mobile", "07. SLA Risk Radar", "Screen 07"),
    ("campus_care_ai_natural_language_search_desktop", "campus_care_ai_natural_language_search_mobile", "08. AI Search Engine", "Screen 08"),
    ("campus_care_equipment_fatigue_recurrence_radar_desktop", "campus_care_equipment_fatigue_recurrence_radar_mobile", "09. Equipment Fatigue Radar", "Screen 09"),
    ("campus_care_executive_operations_analytics_dashboard_desktop", "campus_care_executive_operations_analytics_dashboard_mobile", "10. Executive Analytics", "Screen 10"),
    ("campus_care_confidential_academic_grievance_form_desktop", "campus_care_confidential_academic_grievance_form_mobile", "11. Academic Grievance", "Screen 11"),
    ("campus_care_unified_multi_channel_notification_center_desktop", "campus_care_unified_multi_channel_notification_center_mobile", "12. Notification Center", "Screen 12"),
    ("campus_care_academic_officer_review_disposition_workspace_desktop", "campus_care_academic_officer_review_disposition_workspace_mobile", "13. Officer Disposition", "Screen 13"),
    ("campus_care_ai_maintenance_recommendations_desktop", "campus_care_ai_maintenance_recommendations_mobile", "14. AI Maintenance Engine", "Screen 14")
]

def make_floating_nav(curr_idx, is_mobile=False):
    prev_idx = (curr_idx - 1) % len(SCREENS)
    next_idx = (curr_idx + 1) % len(SCREENS)
    
    target_prev = f"../{SCREENS[prev_idx][1 if is_mobile else 0]}/code.html"
    target_next = f"../{SCREENS[next_idx][1 if is_mobile else 0]}/code.html"
    next_title = SCREENS[next_idx][2]
    prev_title = SCREENS[prev_idx][2]
    
    html = f"""
<!-- CONTINUOUS SEQUENTIAL WORKFLOW NAVIGATOR -->
<div id="sequential-flow-bar" class="fixed bottom-4 right-4 z-50 flex items-center gap-2 bg-[#070235]/90 backdrop-blur-md border border-white/20 px-3 py-2 rounded-2xl shadow-2xl text-white font-sans text-xs">
    <a href="{target_prev}" title="Previous: {prev_title}" class="px-2.5 py-1.5 rounded-xl bg-white/10 hover:bg-white/20 text-slate-300 hover:text-white flex items-center gap-1 transition-all">
        <span class="material-symbols-outlined text-[16px]">arrow_back</span>
        <span class="hidden sm:inline">Prev ({curr_idx:02d}/14)</span>
    </a>
    
    <span class="px-2 py-1 rounded-lg bg-blue-500/20 text-blue-300 font-extrabold text-[11px] border border-blue-400/30">
        Step {curr_idx+1:02d} of 14
    </span>
    
    <a href="{target_next}" title="Next: {next_title}" class="px-3.5 py-1.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-bold flex items-center gap-1 shadow-lg shadow-blue-500/30 transition-all hover:scale-105">
        <span>Next: {SCREENS[next_idx][3]}</span>
        <span class="material-symbols-outlined text-[16px]">arrow_forward</span>
    </a>
</div>
<!-- END CONTINUOUS SEQUENTIAL WORKFLOW NAVIGATOR -->
"""
    return html

def connect_all_in_sequence():
    for idx, (d_folder, m_folder, title, step_tag) in enumerate(SCREENS):
        d_file = os.path.join(BASE_DIR, d_folder, "code.html")
        m_file = os.path.join(BASE_DIR, m_folder, "code.html")
        
        next_d = f"../{SCREENS[(idx + 1) % len(SCREENS)][0]}/code.html"
        next_m = f"../{SCREENS[(idx + 1) % len(SCREENS)][1]}/code.html"
        
        # 1. Desktop Processing
        if os.path.exists(d_file):
            with open(d_file, "r", encoding="utf-8") as f:
                c = f.read()
            
            # Remove any previous sequential navigator
            c = re.sub(r'<!-- CONTINUOUS SEQUENTIAL WORKFLOW NAVIGATOR -->.*?<!-- END CONTINUOUS SEQUENTIAL WORKFLOW NAVIGATOR -->', '', c, flags=re.DOTALL)
            
            # In-page native button transitions
            if idx == 0: # Screen 1 Auth -> Screen 2
                c = re.sub(r'<form\b([^>]*)>', r'<form\1 onsubmit="window.location.href=\'' + next_d + '\'; return false;">', c)
            elif idx == 1: # Screen 2 Switcher -> Screen 3
                if "confirm-workspace-btn" in c:
                    c = re.sub(r'id="confirm-workspace-btn"[^>]*', f'id="confirm-workspace-btn" onclick="window.location.href=\'{next_d}\'"', c)
            elif idx == 2: # Screen 3 Dashboard -> Screen 4
                c = re.sub(r'(<button[^>]*>\s*<span[^>]*>add</span>\s*Report Issue\s*</button>)', f'<a href="{next_d}">\\1</a>', c)
            elif idx == 3: # Screen 4 Voice Filing -> Screen 5
                if "submit-ticket-btn" in c:
                    c = re.sub(r'id="submit-ticket-btn"[^>]*', f'id="submit-ticket-btn" onclick="window.location.href=\'{next_d}\'"', c)
            elif idx == 4: # Screen 5 Tracker -> Screen 6
                c = c.replace('href="#"', f'href="{next_d}"')
            elif idx == 5: # Screen 6 Triage -> Screen 7
                c = c.replace('href="#"', f'href="{next_d}"')
            elif idx == 6: # Screen 7 SLA Radar -> Screen 8
                c = c.replace('href="#"', f'href="{next_d}"')
            elif idx == 7: # Screen 8 AI Search -> Screen 9
                c = c.replace('href="#"', f'href="{next_d}"')
            elif idx == 8: # Screen 9 Equipment Fatigue -> Screen 10
                c = c.replace('href="#"', f'href="{next_d}"')
            elif idx == 9: # Screen 10 Executive KPI -> Screen 11
                c = c.replace('href="#"', f'href="{next_d}"')
            elif idx == 10: # Screen 11 Academic Grievance -> Screen 12
                c = re.sub(r'<form\b([^>]*)>', r'<form\1 onsubmit="window.location.href=\'' + next_d + '\'; return false;">', c)
            elif idx == 11: # Screen 12 Notifications -> Screen 13
                c = c.replace('href="#"', f'href="{next_d}"')
            elif idx == 12: # Screen 13 Officer Review -> Screen 14
                if "submit-disposition-btn" in c:
                    c = re.sub(r'id="submit-disposition-btn"[^>]*', f'id="submit-disposition-btn" onclick="window.location.href=\'{next_d}\'"', c)
            elif idx == 13: # Screen 14 AI Maintenance -> Screen 1
                c = c.replace('href="#"', f'href="{next_d}"')
                
            # Add bottom floating sequence widget
            nav_widget = make_floating_nav(idx, is_mobile=False)
            if "</body>" in c:
                c = c.replace("</body>", nav_widget + "\n</body>")
            else:
                c += nav_widget
                
            with open(d_file, "w", encoding="utf-8") as f:
                f.write(c)
            print(f"Connected Desktop Screen {idx+1:02d} -> {SCREENS[(idx+1)%len(SCREENS)][3]}")

        # 2. Mobile Processing
        if os.path.exists(m_file):
            with open(m_file, "r", encoding="utf-8") as f:
                c = f.read()
            c = re.sub(r'<!-- CONTINUOUS SEQUENTIAL WORKFLOW NAVIGATOR -->.*?<!-- END CONTINUOUS SEQUENTIAL WORKFLOW NAVIGATOR -->', '', c, flags=re.DOTALL)
            
            if idx == 0:
                c = re.sub(r'<form\b([^>]*)>', r'<form\1 onsubmit="window.location.href=\'' + next_m + '\'; return false;">', c)
            elif idx == 1:
                if "confirm-workspace-btn" in c:
                    c = re.sub(r'id="confirm-workspace-btn"[^>]*', f'id="confirm-workspace-btn" onclick="window.location.href=\'{next_m}\'"', c)
            elif idx == 2:
                c = re.sub(r'(<button[^>]*>\s*<span[^>]*>add</span>\s*</button>)', f'<a href="{next_m}">\\1</a>', c)
            elif idx == 3:
                if "submit-ticket-btn" in c:
                    c = re.sub(r'id="submit-ticket-btn"[^>]*', f'id="submit-ticket-btn" onclick="window.location.href=\'{next_m}\'"', c)
            elif idx == 12:
                if "submit-disposition-btn" in c:
                    c = re.sub(r'id="submit-disposition-btn"[^>]*', f'id="submit-disposition-btn" onclick="window.location.href=\'{next_m}\'"', c)

            nav_widget = make_floating_nav(idx, is_mobile=True)
            if "</body>" in c:
                c = c.replace("</body>", nav_widget + "\n</body>")
            else:
                c += nav_widget

            with open(m_file, "w", encoding="utf-8") as f:
                f.write(c)
            print(f"Connected Mobile Screen {idx+1:02d} -> {SCREENS[(idx+1)%len(SCREENS)][3]}")

if __name__ == "__main__":
    connect_all_in_sequence()
    print("All 14 screens connected sequentially 1 -> 2 -> 3 -> ... -> 14 -> 1!")

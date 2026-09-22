import os
import re

BASE_DIR = r"d:\Campus Complaint Management\stitch_screen\stitch_campus_care_authentication_ui"

SCREENS = [
    {
        "id": 1,
        "desktop": "campus_care_desktop_authentication",
        "mobile": "campus_care_mobile_authentication",
        "title": "01. Auth & Persona Switcher",
        "short_title": "Sign In",
        "icon": "lock",
        "category": "Access",
        "desc": "Multi-persona selector, domain switcher, SSO authentication"
    },
    {
        "id": 2,
        "desktop": "campus_care_institution_workspace_switcher_desktop",
        "mobile": "campus_care_institution_workspace_switcher_mobile",
        "title": "02. Institution Workspace Switcher",
        "short_title": "Campus Switcher",
        "icon": "domain",
        "category": "Access",
        "desc": "Stanford, MIT, Berkeley, CMU tenant selection"
    },
    {
        "id": 3,
        "desktop": "campus_care_complaints_dashboard_desktop",
        "mobile": "campus_care_complaints_dashboard_mobile",
        "title": "03. Complaints Operations Dashboard",
        "short_title": "Dashboard",
        "icon": "dashboard",
        "category": "Operations",
        "desc": "Live incident feeds, triage metrics, filter chips"
    },
    {
        "id": 4,
        "desktop": "campus_care_issue_filing_form_with_voice_input_desktop",
        "mobile": "campus_care_issue_filing_form_with_voice_input_mobile",
        "title": "04. Issue Filing Form & Voice AI",
        "short_title": "File Issue",
        "icon": "mic",
        "category": "Reporting",
        "desc": "Live audio waveform, voice memo transcribe, auto-triage"
    },
    {
        "id": 5,
        "desktop": "campus_care_issue_detail_lifecycle_resolution_tracker_desktop",
        "mobile": "campus_care_issue_detail_lifecycle_resolution_tracker_mobile",
        "title": "05. Resolution Lifecycle Tracker",
        "short_title": "Issue Tracker",
        "icon": "track_changes",
        "category": "Operations",
        "desc": "Chronological audit trail, sensor waveforms, parts log"
    },
    {
        "id": 6,
        "desktop": "campus_care_coordinator_triage_workspace_desktop",
        "mobile": "campus_care_coordinator_triage_workspace_mobile",
        "title": "06. Coordinator Triage Desk",
        "short_title": "Triage Desk",
        "icon": "assignment_turned_in",
        "category": "Operations",
        "desc": "Priority classification matrix, technician dispatch"
    },
    {
        "id": 7,
        "desktop": "campus_care_maintenance_supervisor_sla_risk_radar_desktop",
        "mobile": "campus_care_maintenance_supervisor_sla_risk_radar_mobile",
        "title": "07. SLA Risk Radar",
        "short_title": "SLA Radar",
        "icon": "timer",
        "category": "Operations",
        "desc": "Real-time countdown SLA gauges, breach risk radar"
    },
    {
        "id": 8,
        "desktop": "campus_care_ai_natural_language_search_desktop",
        "mobile": "campus_care_ai_natural_language_search_mobile",
        "title": "08. AI Semantic Search Engine",
        "short_title": "AI Search",
        "icon": "travel_explore",
        "category": "Intelligence",
        "desc": "Natural language query synthesis, cross-entity results"
    },
    {
        "id": 9,
        "desktop": "campus_care_equipment_fatigue_recurrence_radar_desktop",
        "mobile": "campus_care_equipment_fatigue_recurrence_radar_mobile",
        "title": "09. Equipment Fatigue Radar",
        "short_title": "Equipment Radar",
        "icon": "electric_bolt",
        "category": "Facilities",
        "desc": "MTBF analysis, vibration telemetry, replacement urgency"
    },
    {
        "id": 10,
        "desktop": "campus_care_executive_operations_analytics_dashboard_desktop",
        "mobile": "campus_care_executive_operations_analytics_dashboard_mobile",
        "title": "10. Executive Analytics Dashboard",
        "short_title": "Executive KPI",
        "icon": "analytics",
        "category": "Executive",
        "desc": "Campus-wide resolution times, cost breakdowns, heatmaps"
    },
    {
        "id": 11,
        "desktop": "campus_care_confidential_academic_grievance_form_desktop",
        "mobile": "campus_care_confidential_academic_grievance_form_mobile",
        "title": "11. Confidential Academic Grievance",
        "short_title": "Grievance Form",
        "icon": "verified_user",
        "category": "Academic",
        "desc": "Encrypted submission, whistle-blower protection, vault upload"
    },
    {
        "id": 12,
        "desktop": "campus_care_unified_multi_channel_notification_center_desktop",
        "mobile": "campus_care_unified_multi_channel_notification_center_mobile",
        "title": "12. Multi-Channel Notification Center",
        "short_title": "Notifications",
        "icon": "notifications_active",
        "category": "Communications",
        "desc": "Push, SMS, Email, In-app dispatch logs, quiet hours"
    },
    {
        "id": 13,
        "desktop": "campus_care_academic_officer_review_disposition_workspace_desktop",
        "mobile": "campus_care_academic_officer_review_disposition_workspace_mobile",
        "title": "13. Officer Review & Disposition",
        "short_title": "Officer Review",
        "icon": "gavel",
        "category": "Academic",
        "desc": "Redacted evidence viewer, committee vote, formal disposition"
    },
    {
        "id": 14,
        "desktop": "campus_care_ai_maintenance_recommendations_desktop",
        "mobile": "campus_care_ai_maintenance_recommendations_mobile",
        "title": "14. AI Predictive Maintenance Engine",
        "short_title": "AI Maintenance",
        "icon": "precision_manufacturing",
        "category": "Intelligence",
        "desc": "Prescriptive capital planning, ROI optimizer, lifecycle scoring"
    }
]

def generate_desktop_nav_header(current_idx):
    curr = SCREENS[current_idx]
    prev_idx = (current_idx - 1) % len(SCREENS)
    next_idx = (current_idx + 1) % len(SCREENS)
    prev_screen = SCREENS[prev_idx]
    next_screen = SCREENS[next_idx]
    
    # Key primary links for the top bar
    primary_nav_items = [
        (2, "Dashboard", "dashboard"),
        (3, "File Issue", "add_circle"),
        (4, "Tracker", "track_changes"),
        (5, "Triage", "assignment_turned_in"),
        (6, "SLA Radar", "timer"),
        (7, "AI Search", "travel_explore"),
        (8, "Fatigue Radar", "electric_bolt"),
        (9, "Executive KPI", "analytics"),
        (10, "Academic Grievance", "verified_user"),
        (12, "Officer Review", "gavel"),
        (13, "AI Maintenance", "precision_manufacturing"),
    ]
    
    nav_links_html = ""
    for idx, label, icon in primary_nav_items:
        is_active = (idx == current_idx)
        target = f"../{SCREENS[idx]['desktop']}/code.html"
        if is_active:
            nav_links_html += f"""
            <a href="{target}" class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-blue-600 text-white font-bold text-xs shadow-md shadow-blue-500/20 transition-all">
                <span class="material-symbols-outlined text-[16px]">{icon}</span>
                <span>{label}</span>
            </a>
            """
        else:
            nav_links_html += f"""
            <a href="{target}" class="inline-flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg text-slate-300 hover:text-white hover:bg-white/10 font-medium text-xs transition-all">
                <span class="material-symbols-outlined text-[16px] text-slate-400">{icon}</span>
                <span>{label}</span>
            </a>
            """
            
    # Dropdown options for all 14 screens
    dropdown_options_html = ""
    for idx, sc in enumerate(SCREENS):
        selected = 'selected' if idx == current_idx else ''
        dropdown_options_html += f"""<option value="../{sc['desktop']}/code.html" {selected}>Screen {sc['id']:02d}: {sc['title']}</option>\n"""

    header_html = f"""
<!-- CAMPUS CARE ENTERPRISE GLOBAL WEBSITE HEADER -->
<header id="campus-care-global-header" class="sticky top-0 z-[9999] bg-[#070235]/95 backdrop-blur-xl border-b border-white/15 text-white shadow-2xl transition-all">
    <div class="max-w-[1700px] mx-auto px-4 py-2.5 flex items-center justify-between gap-4">
        <!-- Logo & Campus Identity -->
        <div class="flex items-center gap-4 flex-shrink-0">
            <a href="../campus_care_complaints_dashboard_desktop/code.html" class="flex items-center gap-2.5 group">
                <div class="w-8 h-8 rounded-lg bg-gradient-to-tr from-blue-700 to-indigo-500 flex items-center justify-center shadow-md shadow-blue-500/30 group-hover:scale-105 transition-transform">
                    <span class="material-symbols-outlined text-[20px] text-white">account_balance</span>
                </div>
                <div class="flex flex-col">
                    <div class="flex items-center gap-1.5">
                        <span class="font-extrabold text-sm tracking-tight text-white group-hover:text-blue-300 transition-colors">CAMPUS CARE</span>
                        <span class="px-1.5 py-0.2 rounded bg-blue-500/30 text-blue-300 border border-blue-400/30 text-[9px] font-bold uppercase tracking-widest">Enterprise</span>
                    </div>
                    <span class="text-[10px] text-slate-400 font-medium leading-none">Stanford University Partition</span>
                </div>
            </a>
            
            <div class="hidden xl:block h-5 w-px bg-white/15"></div>
            
            <!-- Breadcrumb Badge -->
            <div class="hidden xl:flex items-center gap-2 text-xs">
                <a href="../index.html" class="text-slate-400 hover:text-white transition-colors flex items-center gap-1">
                    <span class="material-symbols-outlined text-[14px]">home</span> Hub
                </a>
                <span class="text-slate-600">/</span>
                <span class="text-blue-400 font-bold px-2 py-0.5 rounded bg-blue-500/10 border border-blue-500/20 flex items-center gap-1">
                    <span class="material-symbols-outlined text-[13px]">{curr['icon']}</span>
                    {curr['title']}
                </span>
            </div>
        </div>

        <!-- Continuous Website Navigation Bar -->
        <nav class="hidden lg:flex items-center gap-1 overflow-x-auto py-0.5 max-w-[55vw] no-scrollbar">
            {nav_links_html}
        </nav>

        <!-- Right Action Center -->
        <div class="flex items-center gap-2 flex-shrink-0">
            <!-- Screen Navigator Dropdown -->
            <div class="relative hidden sm:block">
                <select onchange="if(this.value) window.location.href=this.value" class="bg-slate-900/90 text-xs font-semibold text-slate-200 border border-white/20 rounded-lg px-2.5 py-1.5 pr-7 focus:ring-2 focus:ring-blue-500 focus:outline-none cursor-pointer hover:border-blue-400/60 transition-colors appearance-none">
                    {dropdown_options_html}
                </select>
                <span class="material-symbols-outlined text-[16px] text-slate-400 absolute right-2 top-2 pointer-events-none">expand_more</span>
            </div>

            <!-- Sequential Next/Prev Tour Buttons -->
            <div class="flex items-center bg-white/10 rounded-lg p-0.5 border border-white/15">
                <a href="../{prev_screen['desktop']}/code.html" title="Previous: {prev_screen['title']}" class="p-1 rounded hover:bg-white/20 text-slate-300 hover:text-white transition-colors flex items-center">
                    <span class="material-symbols-outlined text-[18px]">chevron_left</span>
                </a>
                <span class="text-[11px] font-bold px-1.5 text-blue-300">{curr['id']}/14</span>
                <a href="../{next_screen['desktop']}/code.html" title="Next: {next_screen['title']}" class="p-1 rounded hover:bg-white/20 text-slate-300 hover:text-white transition-colors flex items-center">
                    <span class="material-symbols-outlined text-[18px]">chevron_right</span>
                </a>
            </div>

            <!-- Notification Center Bell -->
            <a href="../campus_care_unified_multi_channel_notification_center_desktop/code.html" title="Unified Notification Center" class="relative p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-slate-200 hover:text-white transition-colors flex items-center">
                <span class="material-symbols-outlined text-[18px]">notifications</span>
                <span class="absolute -top-1 -right-1 w-4 h-4 rounded-full bg-red-500 text-white text-[9px] font-extrabold flex items-center justify-center animate-pulse">4</span>
            </a>

            <!-- Switch Campus -->
            <a href="../campus_care_institution_workspace_switcher_desktop/code.html" title="Switch University Tenant" class="hidden md:flex items-center gap-1 px-2 py-1.5 rounded-lg bg-emerald-500/20 hover:bg-emerald-500/30 text-emerald-300 border border-emerald-500/30 text-xs font-semibold transition-colors">
                <span class="material-symbols-outlined text-[15px]">sync_alt</span>
                <span class="text-[11px]">Campus</span>
            </a>

            <!-- Switch to Mobile View -->
            <a href="../{curr['mobile']}/code.html" title="Switch to Mobile View for this screen" class="flex items-center gap-1 px-2.5 py-1.5 rounded-lg bg-white/10 hover:bg-blue-600 text-slate-200 hover:text-white text-xs font-semibold border border-white/15 transition-all">
                <span class="material-symbols-outlined text-[15px]">smartphone</span>
                <span class="hidden sm:inline text-[11px]">Mobile</span>
            </a>

            <!-- Sign Out / Persona -->
            <a href="../campus_care_desktop_authentication/code.html" title="Sign Out / Switch Persona" class="p-1.5 rounded-lg bg-red-500/15 hover:bg-red-500/30 text-red-300 border border-red-500/20 transition-colors flex items-center">
                <span class="material-symbols-outlined text-[18px]">logout</span>
            </a>
        </div>
    </div>
</header>
<!-- END CAMPUS CARE GLOBAL HEADER -->
"""
    return header_html


def generate_mobile_nav_header_and_footer(current_idx):
    curr = SCREENS[current_idx]
    prev_idx = (current_idx - 1) % len(SCREENS)
    next_idx = (current_idx + 1) % len(SCREENS)
    prev_screen = SCREENS[prev_idx]
    next_screen = SCREENS[next_idx]

    # Mobile Drawer items
    drawer_links_html = ""
    for idx, sc in enumerate(SCREENS):
        is_active = (idx == current_idx)
        active_class = "bg-blue-600 text-white font-bold" if is_active else "text-slate-300 hover:bg-white/10"
        drawer_links_html += f"""
        <a href="../{sc['mobile']}/code.html" class="flex items-center justify-between px-3 py-2.5 rounded-xl {active_class} text-xs transition-colors">
            <div class="flex items-center gap-2.5">
                <span class="material-symbols-outlined text-[18px]">{sc['icon']}</span>
                <span>{sc['title']}</span>
            </div>
            <span class="text-[10px] opacity-75">{sc['id']}/14</span>
        </a>
        """

    mobile_top_header = f"""
<!-- CAMPUS CARE MOBILE APP GLOBAL TOPBAR -->
<div class="sticky top-0 z-[9999] bg-[#070235]/95 backdrop-blur-xl border-b border-white/15 px-3 py-2.5 flex items-center justify-between text-white shadow-lg">
    <div class="flex items-center gap-2">
        <a href="../{prev_screen['mobile']}/code.html" class="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-slate-300 hover:text-white active:bg-white/20">
            <span class="material-symbols-outlined text-[20px]">arrow_back</span>
        </a>
        <div>
            <div class="flex items-center gap-1.5">
                <span class="text-[11px] font-extrabold uppercase tracking-wider text-blue-400">Screen {curr['id']:02d}/14</span>
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
            </div>
            <h2 class="text-xs font-bold text-white truncate max-w-[180px] leading-tight">{curr['short_title']}</h2>
        </div>
    </div>

    <div class="flex items-center gap-1.5">
        <button onclick="document.getElementById('mobile-screen-drawer').classList.toggle('hidden')" class="px-2 py-1 rounded-lg bg-blue-600 text-white font-bold text-[11px] flex items-center gap-1 shadow-sm">
            <span class="material-symbols-outlined text-[15px]">menu</span>
            <span>All Pages</span>
        </button>
        <a href="../{curr['desktop']}/code.html" title="Switch to Desktop" class="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-slate-300 hover:text-white">
            <span class="material-symbols-outlined text-[18px]">desktop_windows</span>
        </a>
        <a href="../campus_care_unified_multi_channel_notification_center_mobile/code.html" class="relative w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-slate-300 hover:text-white">
            <span class="material-symbols-outlined text-[18px]">notifications</span>
            <span class="absolute top-1 right-1 w-2 h-2 rounded-full bg-red-500"></span>
        </a>
    </div>
</div>

<!-- Mobile Drawer Modal -->
<div id="mobile-screen-drawer" class="hidden fixed inset-0 z-[10000] bg-black/80 backdrop-blur-md flex flex-col justify-end p-3 animate-fade-in">
    <div class="bg-[#0c0836] border border-white/20 rounded-3xl p-4 max-h-[85vh] flex flex-col gap-3 shadow-2xl text-white">
        <div class="flex items-center justify-between pb-3 border-b border-white/10">
            <div class="flex items-center gap-2">
                <span class="material-symbols-outlined text-blue-400">account_tree</span>
                <h3 class="font-bold text-sm">Campus Care Site Map (14 Screens)</h3>
            </div>
            <button onclick="document.getElementById('mobile-screen-drawer').classList.add('hidden')" class="w-7 h-7 rounded-full bg-white/10 flex items-center justify-center text-slate-300">
                <span class="material-symbols-outlined text-[18px]">close</span>
            </button>
        </div>
        <div class="overflow-y-auto flex flex-col gap-1 pr-1 max-h-[60vh]">
            {drawer_links_html}
        </div>
        <div class="pt-2 border-t border-white/10 grid grid-cols-2 gap-2">
            <a href="../index.html" class="py-2.5 rounded-xl bg-white/10 hover:bg-white/20 text-center font-bold text-xs text-slate-200">
                🧭 Master Hub
            </a>
            <a href="../{curr['desktop']}/code.html" class="py-2.5 rounded-xl bg-blue-600 text-center font-bold text-xs text-white">
                🖥️ Desktop View
            </a>
        </div>
    </div>
</div>
<!-- END CAMPUS CARE MOBILE GLOBAL TOPBAR -->
"""

    mobile_bottom_bar = f"""
<!-- CAMPUS CARE MOBILE STICKY BOTTOM NAVIGATION BAR -->
<nav id="campus-care-mobile-bottom-nav" class="sticky bottom-0 z-[9990] bg-[#070235]/95 backdrop-blur-xl border-t border-white/15 px-2 py-1.5 flex items-center justify-around text-white shadow-2xl">
    <a href="../campus_care_complaints_dashboard_mobile/code.html" class="flex flex-col items-center gap-0.5 py-1 px-2.5 rounded-lg {'text-blue-400 font-bold' if current_idx == 2 else 'text-slate-400'}">
        <span class="material-symbols-outlined text-[20px]">dashboard</span>
        <span class="text-[9px]">Dashboard</span>
    </a>
    <a href="../campus_care_issue_filing_form_with_voice_input_mobile/code.html" class="flex flex-col items-center gap-0.5 py-1 px-2.5 rounded-lg {'text-blue-400 font-bold' if current_idx == 3 else 'text-slate-400'}">
        <span class="material-symbols-outlined text-[20px]">add_circle</span>
        <span class="text-[9px]">Report</span>
    </a>
    <a href="../campus_care_maintenance_supervisor_sla_risk_radar_mobile/code.html" class="flex flex-col items-center gap-0.5 py-1 px-2.5 rounded-lg {'text-blue-400 font-bold' if current_idx == 6 else 'text-slate-400'}">
        <span class="material-symbols-outlined text-[20px]">timer</span>
        <span class="text-[9px]">SLA Radar</span>
    </a>
    <a href="../campus_care_confidential_academic_grievance_form_mobile/code.html" class="flex flex-col items-center gap-0.5 py-1 px-2.5 rounded-lg {'text-blue-400 font-bold' if current_idx == 10 else 'text-slate-400'}">
        <span class="material-symbols-outlined text-[20px]">verified_user</span>
        <span class="text-[9px]">Grievance</span>
    </a>
    <a href="../{next_screen['mobile']}/code.html" class="flex flex-col items-center gap-0.5 py-1 px-2.5 rounded-lg text-emerald-400 font-bold bg-emerald-500/10 border border-emerald-500/20">
        <span class="material-symbols-outlined text-[20px]">arrow_forward</span>
        <span class="text-[9px]">Next Step</span>
    </a>
</nav>
<!-- END CAMPUS CARE MOBILE BOTTOM BAR -->
"""
    return mobile_top_header, mobile_bottom_bar


def process_all_screens():
    for idx, sc in enumerate(SCREENS):
        desktop_file = os.path.join(BASE_DIR, sc["desktop"], "code.html")
        mobile_file = os.path.join(BASE_DIR, sc["mobile"], "code.html")
        
        # 1. Update Desktop Screen
        if os.path.exists(desktop_file):
            with open(desktop_file, "r", encoding="utf-8") as f:
                content = f.read()
                
            # Remove any old injected tour bars or headers
            content = re.sub(r'<!-- CAMPUS CARE ENTERPRISE GLOBAL WEBSITE HEADER -->.*?<!-- END CAMPUS CARE GLOBAL HEADER -->', '', content, flags=re.DOTALL)
            content = re.sub(r'<!-- CONTINUOUS GUIDED TOUR NAVIGATION BAR -->.*?<!-- END TOUR NAVIGATION BAR -->', '', content, flags=re.DOTALL)
            
            # Inject new desktop global website header right after <body> or <body ...>
            desktop_header = generate_desktop_nav_header(idx)
            if "<body" in content:
                content = re.sub(r'(<body[^>]*>)', r'\1\n' + desktop_header, content, count=1)
            else:
                content = desktop_header + content
                
            with open(desktop_file, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"Updated Desktop: {sc['desktop']}")

        # 2. Update Mobile Screen
        if os.path.exists(mobile_file):
            with open(mobile_file, "r", encoding="utf-8") as f:
                content = f.read()
                
            content = re.sub(r'<!-- CAMPUS CARE MOBILE APP GLOBAL TOPBAR -->.*?<!-- END CAMPUS CARE MOBILE GLOBAL TOPBAR -->', '', content, flags=re.DOTALL)
            content = re.sub(r'<!-- CAMPUS CARE MOBILE STICKY BOTTOM NAVIGATION BAR -->.*?<!-- END CAMPUS CARE MOBILE BOTTOM BAR -->', '', content, flags=re.DOTALL)
            content = re.sub(r'<!-- CONTINUOUS GUIDED TOUR NAVIGATION BAR -->.*?<!-- END TOUR NAVIGATION BAR -->', '', content, flags=re.DOTALL)
            
            mobile_top, mobile_bottom = generate_mobile_nav_header_and_footer(idx)
            
            if "<body" in content:
                content = re.sub(r'(<body[^>]*>)', r'\1\n' + mobile_top, content, count=1)
            else:
                content = mobile_top + content
                
            if "</body>" in content:
                content = content.replace("</body>", mobile_bottom + "\n</body>")
            else:
                content = content + mobile_bottom
                
            with open(mobile_file, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"Updated Mobile: {sc['mobile']}")

if __name__ == "__main__":
    process_all_screens()
    print("Successfully connected all 14 screens into a continuous website experience!")

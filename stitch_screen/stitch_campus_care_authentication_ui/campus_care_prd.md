# Campus Care — Product Requirements Document

**AI-Powered Facilities & Academic Issue Tracker · Non-Technical Version**

---

## 1. What Is This Product?

Campus Care is a smart complaint and issue-reporting system for colleges and universities.

Students and staff can report problems they face on campus — a broken projector, a faulty AC, a wifi dead zone, a library issue, or an exam-related concern — and the system makes sure that problem is seen, understood, assigned to the right person, tracked until it's fixed, and confirmed as actually resolved.

It's built around one simple idea:

> **Every problem reported on campus should have a clear story, a clear owner, visible progress, and a clear next step — until it is genuinely resolved.**

Unlike a basic complaint box or a simple ticket log, Campus Care uses AI throughout the process to help everyone involved — students, facilities staff, and college administration — understand what's happening, spot patterns, and act faster.

**Product Stage:** College Project, built with a real-world product mindset.

## 2. Why This Product Is Needed

Anyone who has studied or worked on a campus has experienced this:

> You report that the AC in your classroom is broken. A week later, it's still broken. You don't know who is handling it, whether anyone has even looked at it, or if it's been forgotten entirely.

This happens because of common, everyday problems:

- Complaints get lost between departments
- Nobody knows who is responsible for fixing what
- The same issue gets reported by multiple people separately, with nobody realizing it's the same problem
- Small issues are reported once, ignored, and then reported again and again
- Facilities staff spend time reading long, messy complaint threads instead of fixing things
- Urgent issues (like an AC breaking down right before an exam) get treated the same as routine ones
- Management only finds out about a serious, recurring problem much later than they should

A simple complaint form just records that a problem exists. Campus Care actually helps people **understand and manage** it — from the moment it's reported to the moment it's genuinely fixed.

## 3. Who Uses This Product

Campus Care is designed for five types of people, each with a different view of the system.

### 3.1 Student / Staff Member (the "Reporter")

Anyone who notices a problem — a broken projector, AC issue, library problem, or an academic concern — and reports it.

**They want to:** report a problem quickly and easily, and stay informed about what's happening with it.

### 3.2 Facilities Coordinator (the "Operator")

The person who actually handles the reported issue — reviewing it, assigning the right technician, and tracking it to resolution.

**They want to:** understand the issue quickly and get it resolved without confusion.

### 3.3 Facilities Supervisor (the "Team Lead")

Oversees a team of coordinators and technicians.

**They want to:** know which issues are falling behind, and step in when needed.

### 3.4 Campus Operations Head (the "Manager")

Responsible for how well the whole campus facilities operation is running.

**They want to:** see overall trends, recurring problems, and how well issues are being resolved across campus.

### 3.5 System Administrator

Manages the people, categories, buildings, and settings behind the scenes.

**They want to:** keep the system correctly configured for the institution's real structure (buildings, departments, teams).

## 4. What Each Person Sees

Everyone gets a different experience suited to their role — nobody sees an overwhelming, one-size-fits-all screen.

| Role | What they see |
|---|---|
| Student / Staff Reporter | Their own reported issues and current status; updates and questions from facilities staff; a simple way to confirm once an issue is actually fixed |
| Facilities Coordinator | Issues assigned to them; new issues needing attention; AI insights about each issue; issues at risk of running late |
| Facilities Supervisor | Their team's overall workload; issues needing urgent attention or intervention; patterns worth noticing (e.g. equipment failing repeatedly) |
| Campus Operations Head | Big-picture trends across campus; which buildings or categories have the most issues; how quickly issues are resolved |
| Administrator | Buildings, rooms, departments, categories; who is on which team; a record of important actions taken in the system |
## 5. How AI Helps (Explained Simply)

The system uses AI as a helpful assistant throughout the process — not as a chatbot you have to talk to separately, and never as something that makes final decisions on its own. Every AI suggestion can be reviewed, changed, or rejected by a human.

### 5.1 Understands the Problem Automatically

When someone reports an issue, AI reads the description and figures out:

- What type of problem it likely is (AC, projector, wifi, library, exam-related, etc.)
- How urgent it seems
- What information might be missing (e.g. "which room number?")

### 5.2 Notices When Timing Makes Something Urgent

The AI doesn't just look at *what* was reported — it also considers *when* and *why* it matters right now.

Example: "AC broken in Room 204, exam starts in 20 minutes" is treated as far more urgent than "AC broken, but the room is empty this week" — even though both mention the same equipment.

### 5.3 Spots the Same Problem Being Reported by Multiple People

If several students report "no wifi in the library" within a short time, the AI recognizes this is likely one shared problem, not five separate ones — and groups them together so facilities staff can act on it once, instead of getting flooded with repeated reports.

### 5.4 Notices Repeated Problems Over Time

If the same projector or AC unit keeps breaking down again and again over weeks, the AI flags this as a **recurring issue** — suggesting that a permanent fix or replacement may be needed, instead of the same temporary repair every time.

### 5.5 Suggests What Worked Before

When a new issue comes in, AI can check whether a similar issue was resolved successfully in the past, and suggest that same fix to save time.

### 5.6 Helps Write Clear Updates

Instead of a facilities coordinator writing the same kind of message over and over, AI can draft a simple update ("Your projector issue has been logged, our team will inspect within 2 hours") which the coordinator can review and send.

### 5.7 Warns Before Deadlines Are Missed

If an issue is taking longer than expected and is at risk of missing its expected resolution time, the AI highlights it early — so a supervisor can step in before it becomes a bigger problem.

### 5.8 Summarizes Long, Complicated Issues

For issues that go back and forth for a while, AI keeps a short, up-to-date summary of what's happened so far, so nobody has to read through the entire history to understand where things stand.

### 5.9 Creates a Simple Weekly Overview for Management

AI can generate a plain-language weekly summary for campus leadership, such as: *"This week: 42 issues reported. Wifi complaints increased, mostly from the library. Two pieces of equipment have been flagged as needing replacement."*

## 6. The Journey of a Reported Issue

Every issue goes through a clear, understandable journey:

**Reported → Understood → Assigned → Being Investigated → Action Taken → Marked as Resolved → Confirmed by Reporter → Closed**

Along the way, an issue might also temporarily be:

- **Waiting for more information** (if something important is unclear)
- **Escalated** (if it needs higher-level attention)
- **Reopened** (if the reporter says it isn't actually fixed)

At any point, anyone involved can look at the issue and immediately understand what has happened, without needing to ask someone else to explain it.

## 7. What Happens When Someone Reports a Problem — A Simple Example

A student notices the projector isn't working in their classroom, 15 minutes before class starts.

1. They open the app, select "Report an Issue," describe the problem, and submit it.
2. The system immediately gives them a reference number for their report.
3. AI reads the description and recognizes this is urgent, since class is about to start.
4. The right facilities coordinator is notified immediately.
5. A technician is sent to fix it.
6. The student receives an update once it's resolved.
7. The student confirms that the projector is now working.
8. The issue is marked as closed, with the full history saved.

If, instead, three different students report the same wifi outage in the library at the same time, the system recognizes they're describing the same underlying problem and treats it as a single issue for the IT team to resolve — rather than three separate, disconnected complaints.

## 8. Keeping Humans in Control

AI is there to help, not to take over decision-making. This means:

- AI never presents a guess as a confirmed fact. If it's not sure, it says so clearly (e.g. "This looks like it might be a wifi issue" rather than "This is a wifi issue").
- Every person can accept, change, or completely ignore an AI suggestion.
- Two issues are never automatically merged or closed by AI alone — a human always makes that final call.
- If the AI system is temporarily unavailable, the whole platform still works normally — issues can still be reported, assigned, and resolved by people, just without the extra AI suggestions for a while.

## 9. Keeping Everything Fair, Private, and Traceable

- Students and staff can only see their own reported issues — not anyone else's.
- Internal notes used by facilities staff are never visible to the person who reported the issue.
- Every important action taken in the system (who assigned what, who changed a priority, who resolved an issue) is recorded, so there's always a clear record of what happened and who did it.

## 10. What Success Looks Like

Campus Care will be considered successful if it can genuinely show that it:

1. Captures a real problem reported by a student or staff member.
2. Keeps the complete story of that problem in one place.
3. Lets the right people work together to resolve it.
4. Uses AI in a way that actually helps, not just for show.
5. Helps people figure out what needs to happen next.
6. Notices problems that need urgent attention before they're missed.
7. Keeps the person who reported the issue informed the whole way through.
8. Makes sure issues don't disappear into a forgotten queue.
9. Lets humans override AI whenever they disagree with it.
10. Gives campus leadership a clear, honest picture of how facilities issues are being handled overall.

The single most important question this product needs to answer is:

> **Does this genuinely make campus issue reporting and resolution better than a simple complaint form or ticket log?**

## 11. What's Included in the First Version (MVP)

The first version of Campus Care will focus on facilities-related issues (AC, projectors, wifi, lab equipment, library issues), since these are the clearest, most common, and least sensitive problems to solve first.

**For Students / Staff:**

- Report a new issue with a description and photos
- View their own reported issues and their status
- Respond to questions from facilities staff
- Confirm whether an issue is actually resolved

**For Facilities Coordinators:**

- View issues assigned to them
- Review AI's understanding of each issue
- Communicate with the person who reported it
- Update the issue's progress
- Mark an issue as resolved

**For Facilities Supervisors:**

- View their team's overall workload
- Review issues that are at risk or need attention
- Step in and reassign issues when necessary

**For the Campus Operations Head:**

- View overall trends and performance across campus
- See which categories or buildings have the most reported issues

**For the Administrator:**

- Manage buildings, categories, and system settings
- Manage who belongs to which team

## 12. How the System Manages Its Data (ORM & Database Migrations)

Behind the scenes, Campus Care needs a reliable way to store and evolve all the information it keeps — issues, users, buildings, teams, notes, AI insights, and history.

- **ORM (Object-Relational Mapping) Tool:** The system will use an ORM tool to connect the application to the database. Instead of writing raw database queries by hand everywhere, the ORM lets the development team work with the data (issues, users, buildings, etc.) as simple, structured objects in code, while the ORM handles translating that into safe, consistent database operations underneath.
- **Database Migrations:** As Campus Care grows from the first version (MVP) into later phases — adding academic concerns, new AI features, or multi-institution support — the shape of the stored data will need to change (new fields, new tables, new relationships). A database migration tool will be used to make these changes in a controlled, versioned, and repeatable way, so that:
  - Every change to the database structure is recorded and can be reviewed, like a change history for the data itself.
  - The same set of changes can be applied consistently across development, testing, and the live system, without manual guesswork.
  - If something goes wrong, a migration can be rolled back safely instead of the database being left in a broken or inconsistent state.

This ensures Campus Care's data foundation stays stable, traceable, and safe to evolve as new features are added phase by phase.

## 13. Automated Communications (SMS, WhatsApp, Email)

Campus Care will not rely only on in-app notifications. Important moments in a user's experience will also be communicated automatically through the channels people actually check day to day.

- **Welcome Email:** When a new user's account is created (or they log in for the very first time), the system will automatically send a welcome email introducing them to Campus Care and how to report or manage issues.
- **Login Notifications:** Each time a user logs in, the system will automatically send a notification to their registered devices — via SMS, WhatsApp, and/or Email — so they know when and that their account was accessed. This adds a layer of visibility and account security for every reporter and staff member.
- **Issue & Status Notifications:** In addition to in-app updates, key moments in an issue's journey (assigned, updated, resolved, waiting for confirmation, reopened) will also be pushed out automatically through SMS, WhatsApp, and Email, so people stay informed even when they're not actively using the app.
- **User Choice:** Where possible, users will be able to choose which of these channels (SMS / WhatsApp / Email / in-app only) they prefer for non-critical updates — though certain notifications, like login alerts and the welcome email, will always be sent automatically for safety and onboarding purposes.

These automated communications work the same way as the rest of the system's AI-assisted messaging (see Section 5.6): messages are templated and triggered automatically, but nothing here overrides a human decision — they simply keep people informed in real time, wherever they are.

## 14. What Comes Later (Future Ideas, Not Part of the First Version)

Once the core product is working well, it could later grow to include:

- Handling academic-related concerns (like exam grievances) with appropriate extra care
- Reporting issues by voice instead of typing
- Searching for issues using natural, everyday language (e.g. "show me all unresolved wifi issues from this month")
- A dedicated mobile app, in addition to the web-based version
- Supporting multiple institutions on the same platform
- More advanced pattern-spotting across years of historical data

These are treated as ideas for later, not requirements for the first working version.

## 15. The Big Picture

Campus Care connects:

**People → Reported Issues → Evidence (photos) → Communication → AI Insights → Deadlines → Resolution**

The goal is to change the experience from:

> "I reported it. Now I wait and hope someone remembers."

into:

> "I reported it, I know it's being handled, I can see progress, and I'll know for sure once it's actually fixed."

The guiding principle behind the whole product is simple:

> **The system keeps track of every issue. AI helps people understand it and move it forward faster. People always make the final decisions.**

# Smart PACE Staff App: Backend API Requirements

| | |
|---|---|
| **Audience** | Backend / ERP API team |
| **Product** | Smart PACE, Staff side (the mobile mini-ERP for staff of the 9 schools) |
| **Prepared** | 26 Oct 2026 |
| **Source** | Read from the mobile app code (`lib/staff/**`, `lib/core/**`). Everything under "As implemented" is what the app sends today. Everything under "Requested" is a proposal for you to confirm or change. |

> The Careers (candidate) side of the app is a separate, already-live product and is **out of scope**. Nothing here changes it.

---

## 1. Summary

The staff app is a phone-sized view of the desktop ERP. The desktop ERP stays the system of record. The app is for moderate operations and for reading important details without a desktop.

**What works today:** sign-in, role-driven menu, personal attendance calendar, class attendance (grades, sections, students, mark), my tickets, manage tickets, notifications, profile and documents, NFC card mapping.

**What the new UI already shows but has no data for ("Soon" in the app):** Events, Tasks, Leave, Timetable, Notices, Approvals, Reports, Staff directory, Fees, Documents, Calendar, Inventory, Settings.

**What is missing for production, in one list:**

| # | Gap | Priority |
|---|---|---|
| 1 | Session security: proper logout, device-token unregister, token expiry contract, credentials moved out of the request body | **P0** |
| 2 | Change password, forgot / reset password | **P0** |
| 3 | Home dashboard summary (one call instead of three) | **P0** |
| 4 | Events (Home "Today's events" and the Events tab) | **P0** |
| 5 | Leave: balance, apply, history, cancel (Home "Leave left" card) | **P0** |
| 6 | Tasks: list, detail, update (Home "Tasks due" card and Tasks tab) | **P0** |
| 7 | Push notification payload contract, FCM token refresh | **P0** |
| 8 | Notices, Approvals, Staff directory, Timetable | P1 |
| 9 | Personal-info update, notification preferences, documents upload | P1 |
| 10 | App version / forced-update check for staff | P1 |
| 11 | Reports, Fees, Inventory, Calendar, Settings | P2 |
| 12 | Face attendance and geofence (code exists, held back from this release) | P2 |

Sections 4 to 6 give the full detail. Section 9 lists the questions we need answered first.

---

## 2. How the app talks to the backend today

**Base URL** (per school): `https://{schoolCode}.paceeducation.com/erp-api/`

The school code is chosen at sign-in and stored on the device. Each school is its own host.

**Endpoint style:** one PHP router, `index.php?page=<module>`, always `POST`, body is `multipart/form-data`. The operation is chosen by an `action` field.

| Page | Used for |
|---|---|
| `login` | Sign in |
| `userMenu` | Role menu and notification count |
| `userProfile` | Staff profile and documents |
| `userAttendance` | Personal attendance calendar |
| `classAttendance` | Grades, class roster, mark attendance |
| `manageNotification` | Notification list and mark-read |
| `tickets` | Raise and view my tickets |
| `manageTickets` | Handle tickets (maintenance, IT, admin) |
| `logout` | **Defined in the app but never called** |
| (separate host) `paceeducation.com/website/transport/{school}/index.php` | NFC tag mapping |

**Authentication as implemented:**

- `POST login` returns a `token`. The app stores it in local storage.
- Every later call sends **`admin_id` and `token` as form fields in the body**. A few calls also send a `token` header.
- The app supports several saved accounts on one device ("Switch user") and sends whichever is active.

**Response style:** JSON with `status` (bool), `message`, `data`, and sometimes `count`. The app tolerates PHP warnings printed before the JSON, but this should not rely on that.

**Errors:** the app does not rely on HTTP status codes for most calls. It checks `status` in the body. See section 3.

---

## 3. Conventions we are asking for (all new endpoints, and fixes to old ones)

These keep the app simple and the API safe. Exceptions are fine if you tell us.

1. **Keep the existing shape** so the app needs no new networking code: `POST index.php?page=<module>`, form-data, `action` selects the operation.
2. **Send credentials in a header only**: `token: <token>`. Stop requiring `admin_id` and `token` in the body. The server should derive the user from the token. (Today a client can send any `admin_id`; the server must not trust it.)
3. **Use real HTTP status codes** alongside the JSON envelope:
   - `200` success, `400` validation, `401` token missing / expired / revoked, `403` role not allowed, `404` not found, `409` conflict, `422` business-rule failure, `429` rate limited, `5xx` server fault.
   - The app will log the user out on `401` and show the `message` on everything else.
4. **Standard envelope**, always valid JSON with no PHP notices before it:
   ```json
   { "status": true, "message": "OK", "data": { }, "count": 0 }
   ```
   On failure: `{ "status": false, "message": "Human readable reason", "code": "LEAVE_OVERLAP" }`. `code` is optional but strongly preferred for rules the app should react to.
5. **Pagination** for every list that can grow: request `pageNo` (0-based) and `limit`, response `count` (total) and `has_more` (bool). The notification endpoint already uses `pageNo` and `limit2`; keep that for notifications.
6. **Dates and time zones:** send dates as `YYYY-MM-DD` and date-times as ISO 8601 with offset (for example `2026-10-26T09:30:00+04:00`). Today attendance mixes `dd/MM/yyyy` and ISO. Please move to ISO for new work.
7. **IDs:** return IDs as integers or consistently as strings. Today ticket IDs are ints, ticket type IDs are strings, and `user_id` is a string. Pick one per field and keep it.
8. **Files:** accept `multipart/form-data`; return a stable absolute URL for downloads; state the max size and allowed types per endpoint.
9. **Role enforcement on the server.** The menu is role-driven, but every endpoint must also check the role. A hidden menu item is not security.
10. **Timeouts:** the app uses a 15 s connect timeout and up to 25 s read for normal calls, 60 s for uploads. Keep typical responses under 1 s and list responses under 100 KB per page.
11. **Idempotency** for create calls (leave apply, ticket raise, task create): accept an optional `client_request_id` and return the original result if it is replayed. Phones retry on weak networks.
12. **Rate limit** login and password endpoints (`429` with `Retry-After`).

---

## 4. Endpoints that exist today

Each entry shows what the app sends and reads **as implemented**, then what we **request**. "Confirm" means we believe this is right from the code but cannot see the server.

### 4.1 `login`

**As implemented**

```
POST index.php?page=login        (no token)
username, password, action=login, fcm_token
```

Reads: `status`, `message`, `data.token`, `data.id`, `data.name`, `data.designation`, `data.photo`, `data.sch_name`, `data.sch_logo`.

If the device has no push token the app sends the literal string `NO TOKEN`.

**Requested**

- Return `401` for wrong credentials (not `200` with `status:false`), and a clear `message`.
- Add to `data`: `role` (principal, supervisor, teacher, nanny, maintenance, admin, director, ...), `school_code`, `token_expires_at`, and a `refresh_token` if you support refresh. See 5.1.
- Accept `device_id`, `platform` (`ios` / `android`), `app_version` so you can manage tokens per device.
- Do not accept the placeholder `NO TOKEN`; treat a missing FCM token as "no push yet".
- Rate limit and lock out repeated failures.

### 4.2 `userMenu`

**As implemented**

```
POST index.php?page=userMenu
admin_id, token, version=<app version, e.g. 1.0.0>
```

Reads: `status`, `message`, `count` (unread notifications), `data[]` of:
`id`, `menu_key`, `menu_val`, `menu_name`, `page`, `icon_url`, `parent_id`, `sub_menu[]` (same shape).

How the app uses it:

- Each item's **`page`** is opened as an app route. Pages the app can open today: `userAttendance`, `tickets`, `manageTickets`, `classAttendance`, `students`, `nfcMapping`, `userProfile`. Any other `page` value will not open anything until the screen ships.
- Items with a `sub_menu` open a sub list.
- The app currently hides the page `faceAttendance` even if returned.
- The app requires `menu_val`, `menu_name`, `icon_url` and `parent_id` to be non-null; a null will break parsing.

**Requested**

- **Do not return a new `page` key until we confirm the screen is in the release.** We will agree the key names in section 5 (`leave`, `tasks`, `events`, and so on).
- Make `page`, `icon_url`, `parent_id` nullable-safe, or always return empty strings.
- Use the sent `version` to withhold items the installed app cannot open.
- Add `badge` (int, optional) per item so the Menu can show counts (open tickets, pending approvals).
- Return `count` as an integer always.

### 4.3 `userProfile`

**As implemented**

```
POST index.php?page=userProfile
admin_id, token
```

Reads `data.user` (`id, ad_username, name, designation, gender, ad_group, stat, photo, title, alias, academic_stat, phone, email`), `data.emp` (HR record: `empId, empl_code, empl_name, designation, join_date, job_conf, dob, sex, mStatus`, passport / visa / Emirates ID / licence numbers and expiry dates, and more), `data.alert` (document alert flag), `data.photo`, and `data.doc[]` (`id, document, issue_stat, expiry_stat, alert_days, stat, alias, doc_no, file_name, expiry_date, issue_date`).

The app shows name, designation, photo, the document count, and a Documents sheet.

**Requested**

- `data.emp.join_date`, `job_conf` and `dob` are parsed as dates and will crash the screen if empty or `0000-00-00`. Return `null` and the app will handle it; do not return zero dates.
- Add `data.user.role` and `data.school` (`name`, `code`, `logo`).
- Return `data.photo` as an absolute URL.
- Document files: return a signed, expiring `download_url` per document (see 5.9).
- Sensitive HR fields (visa, passport, Emirates ID numbers) should only be returned if the app will show them. Tell us which to drop.

### 4.4 `userAttendance` (my attendance calendar)

**As implemented**

```
POST index.php?page=userAttendance
admin_id, token, month (1-12), year
```

Reads `status`, `message`, `data[]` with `user_id, attDate (ISO date), check_in (int), check_out (int), check_in_time, check_out_time, stat`.

The app computes the month percentage, absences, days present and today's status **on the phone** from this list.

**Requested**

- Define the full list of `stat` values (present, absent, late, leave, holiday, weekend, half day) in writing.
- Include holidays and weekends in `data` or in a separate `holidays[]`, so the percentage is not wrong. Today the phone cannot tell a weekend from an absence.
- Add a server-calculated `summary` object (`present_days, absent_days, late_days, leave_days, working_days, percentage`) so the phone and desktop never disagree.
- Add `data.today` with the live check-in and check-out so Home can show "Not marked" correctly.

### 4.5 `classAttendance` (three operations on one page)

**A. Grades and sections (as implemented)**

```
POST index.php?page=classAttendance
admin_id, token
```

Reads `data.grades[]` (`class_key, class_value, sections[]`) and `data.default`.

**B. Students for a class and date (as implemented)**

```
admin_id, token, gr=<class key>, sec=<section>, date=dd/MM/yyyy
```

Reads `data.students[]` (`studcode, fullname, famcode, fname, mobile, class, section, last_yr_class, last_yr_sec, join_stat, SECONDLANG, STDSEX, acdyear, RELIGION, JOINDATE, NATIONAL, HOUSE, DOB`, and `att` = `{id, studcode, comment, remark, att}`) and `data.remarks[]`.

**C. Mark attendance (as implemented)**

```
admin_id, token, gr, sec, date=dd/MM/yyyy, status=<type>, attList=<list of {id, studcode, comment, remark, att}>
```

The app does **not** read the response. It reports success regardless.

**Requested**

- Split into explicit `action` values: `get_grades`, `get_students`, `mark_attendance`.
- **`mark_attendance` must take one JSON string field (`att_list`)** and return the saved rows. Sending a list of objects as repeated form fields is ambiguous. Please define the exact format. The app will be updated to match.
- Return `status:false` plus a message if the class is locked, the date is in the past beyond the allowed window, or the teacher is not assigned to this class. The app will then show the real error.
- Return the saved attendance summary (present, absent, late counts) after marking.
- Enforce "teacher can only mark own classes" on the server.
- Student data returned here includes DOB, religion, nationality and mobile. Please confirm that the role is allowed to see each field; tell us which we can drop.

### 4.6 `manageNotification`

**As implemented**

```
List:      admin_id, token, limit2=20, pageNo=0
Mark read: admin_id, token, notificationId=<id>
Read all:  admin_id, token, notificationId=0
```

Reads `status`, `message`, `count`, `data[]` with `id, notification, page_id, link, read_stat, date_time_added, date_added, log_time, days, time_ago, app_page, head`.

**Requested**

- Use explicit `action` values: `list`, `mark_read`, `mark_all_read`, `unread_count`.
- Return `unread_count` separately from the list `count` (they are mixed today).
- Return a structured deep link instead of free text: `type`, `target_id`, `app_page` (see section 6).
- Add `delete` and `delete_all` if you want users to clear the list.

### 4.7 `tickets` (my tickets)

**As implemented**

```
List mine:   admin_id, token, action=my_tickets, requester_id
One ticket:  admin_id, token, ticket_id
Form config: admin_id, token, action=get_ticket_config
Raise:       admin_id, token, action=raise_ticket, requester_id,
             ticket_type_id, category_id, location_id, priority_id,
             description, attachment (optional file)
```

Reads, per ticket: `ticket_id (int), description, created_at, ticket_type, category, location_name, block_name, priority_name, status_name, color (hex), end_stat (null/0 open, other closed), attachment (URL or null)`.

Form config: `types[] (type_id, type_name)`, `categories[] (category_id, type_id, name)`, `priorities[] (priority_id, priority_name)`, `blocks[] (block_id, block_name)`, `locations[] (location_id, block_id, location_name)`.

Raise returns `status`, `message`.

**Requested**

- Return the **new ticket (id and fields)** from `raise_ticket`, not only a message, so the app can open it.
- Add a comments / activity timeline per ticket to `ticket_id` (see 5.8).
- Add `cancel_ticket` for the requester while still open.
- State the attachment limit (size, types) and return a clear `422` if exceeded. Support more than one attachment if wanted.
- Make `end_stat` explicit: add `is_closed` (bool).
- The ticket list is not paginated. Add `pageNo` and `limit`.

### 4.8 `manageTickets` (handle tickets)

**As implemented**

```
List:        admin_id, token, action=<null | assigned>, end_stat=<null | int>
One ticket:  admin_id, token, ticket_id
Accept:      admin_id, token, ticket_id, action=accept_ticket
Set status:  admin_id, token, ticket_id, action=update_status, status_id, comment
```

Reads a list with the ticket fields above plus `requester_name`, `assigned_to (int or null)`, `status_options[] (status_id, status_name, color)`, and a count object `{unassigned, assigned_active, assigned_closed}`.

**Requested**

- Same envelope and status-code rules as above. Return the updated ticket after `accept_ticket` and `update_status`.
- Return `409` if the ticket was already accepted by someone else.
- Add `assign_ticket` (to another staff member), `reassign`, and `add_comment` if managers need them.
- Add pagination and a text `search`.
- Add `requester_phone` or a "call requester" field only if the role may see it.

### 4.9 NFC card mapping (transport)

**As implemented**

```
POST https://paceeducation.com/website/transport/{schoolCode}/index.php?
page=assignNFCTag, ACTION=ADD|DELETE, STUD_CODE, NFC_TAG
```

**There is no `token` and no `admin_id` on this call.** Anyone who knows the URL can assign or delete tags.

**Requested (P0 if NFC ships in this release, otherwise P2)**

- Require the same `token` header and validate the role.
- Move it under the school API host.
- Return the student name and the previous tag when you replace a tag, so the app can ask the user to confirm.
- Return `409` if the tag is already assigned to another student.

---

## 5. Endpoints that are missing

Naming follows the existing style (`index.php?page=...&action=...`). Fields marked `?` are optional. Where we say "role" we mean the role returned at login.

### 5.1 Session and security (P0)

The app currently has no server-side logout, no token expiry handling and no password change.

| Action | Request | Response |
|---|---|---|
| `page=logout` (already named in the app, **never called**) | header `token`; `fcm_token?`, `device_id?` | `{status}`. Server **revokes the token and deletes the device's push token.** Today a logged-out phone keeps receiving pushes for the previous user. |
| `page=registerDevice` | `fcm_token`, `device_id`, `platform`, `app_version` | `{status}`. App calls this at login and **whenever Firebase rotates the token** (the app currently only logs a rotation and never tells the server, so pushes silently stop). |
| `page=refreshToken` (if you issue short-lived tokens) | `refresh_token` | `{token, token_expires_at}` |
| `page=changePassword` | `current_password`, `new_password` | `{status, message}`. The screen exists in the app but has **no API behind it**. |
| `page=forgotPassword` | `username`, `school_code` | Sends a reset link or OTP. Return the same message whether or not the user exists. |
| `page=resetPassword` | `username`, `otp` or `reset_token`, `new_password` | `{status}` |

Rules we need:

- Password policy returned as text (`min length`, character rules) so the app can show it before submit.
- On `changePassword`, optionally revoke all other sessions and tell the app whether to log the user out.
- Token lifetime and the behaviour on expiry: `401` with `code: TOKEN_EXPIRED`.
- Multi-account: one phone can hold several accounts. Each has its own token. `logout` must only revoke the token sent.

### 5.2 Home dashboard summary (P0)

Home currently makes three separate calls on each refresh (attendance month, menu, my tickets, at most once every 45 seconds) and calculates counts on the phone.

```
POST index.php?page=dashboard      header: token
```

```json
{
  "status": true,
  "data": {
    "attendance": { "today": { "check_in": "08:02", "check_out": null, "status": "present" },
                    "month": { "percentage": 96.5, "absent_days": 1, "present_days": 18, "late_days": 2 } },
    "tickets":    { "open": 2 },
    "tasks":      { "due_today": 3, "overdue": 1 },
    "leave":      { "balance": [ { "type": "Annual", "remaining": 12.5 } ] },
    "unread_notifications": 4,
    "events_today": 2,
    "approvals_pending": 5
  }
}
```

Fields for modules not live yet may be `null`. The app already shows "Soon" for any `null`. Cache-friendly: please support `ETag` / `If-None-Match`.

### 5.3 Events (P0)

Screens: **Home "Today's events"** (up to 3 shown, "+N more") and the **Events tab** (agenda by day, with a month view later).

The app is ready for this: it calls a single function "events on this day". Only the data source needs to be connected.

```
POST index.php?page=events
```

| Action | Request | Response |
|---|---|---|
| `list` | `from` (date), `to` (date), `pageNo?`, `limit?`, `category?`, `school_scope?` | `data[]` of events |
| `today` | none (server uses the school's local date) | `data[]` of today's events |
| `detail` | `event_id` | one event with full description and attachments |
| `rsvp` (optional, later) | `event_id`, `response` (`going` / `not_going`) | `{status}` |

Event object:

```json
{
  "event_id": 311,
  "title": "Staff meeting",
  "description": "Agenda in the attached PDF",
  "starts_at": "2026-10-26T09:30:00+04:00",
  "ends_at":   "2026-10-26T10:15:00+04:00",
  "all_day": false,
  "location": "Conference Room 2",
  "category": "meeting",
  "audience": "all_staff",
  "color": "#F5B544",
  "attachments": [ { "name": "agenda.pdf", "url": "https://..." } ],
  "created_by": "Principal Office"
}
```

Decisions needed:

- **Audience scope:** whole-group events, one-school events, role-specific events (for example "teachers only"). The server must filter so a user only receives what applies. State the rules.
- All-day events and multi-day events: confirm how `starts_at` / `ends_at` represent them. The app sorts all-day first, then by start time.
- Time zone: the school's local zone, sent with offset.
- Does the desktop ERP already have a calendar module? If yes, expose it; if not, we need a small admin screen to create events.
- Push: a reminder before an event (see section 6).

### 5.4 Leave (P0)

Screens: Menu → Leave, Home **"Leave left"** card.

```
POST index.php?page=leave
```

| Action | Request | Response |
|---|---|---|
| `balance` | none | `data[]`: `{leave_type_id, type, entitled, taken, pending, remaining}`. Home shows the total or the main type. |
| `types` | none | `data[]`: `{leave_type_id, name, requires_document, half_day_allowed, max_days}` |
| `apply` | `leave_type_id`, `from_date`, `to_date`, `half_day?` (`am`/`pm`), `reason`, `attachment?` (file), `client_request_id?` | The created request. Return `422` + `code` for overlap, insufficient balance, blackout dates, or missing document. |
| `list` | `status?` (`pending` / `approved` / `rejected` / `cancelled`), `year?`, `pageNo`, `limit` | `data[]`: `{request_id, type, from_date, to_date, days, status, reason, approver_name, approver_comment, applied_at}` |
| `detail` | `request_id` | Full request with the approval trail |
| `cancel` | `request_id` | Allowed only while pending (or by policy) |

For approvers see 5.6 (Approvals). Business rules to confirm: working-day calculation (weekends and holidays), notice period, who approves (line manager, principal, HR), whether balance is deducted on apply or on approval.

### 5.5 Tasks (P0)

Screens: Menu → Tasks, the **Tasks tab**, Home **"Tasks due"** card and **"My tasks"** list.

```
POST index.php?page=tasks
```

| Action | Request | Response |
|---|---|---|
| `list` | `scope` (`mine` / `assigned_by_me` / `team`), `status?` (`open` / `in_progress` / `done`), `due_from?`, `due_to?`, `pageNo`, `limit` | Tasks plus counts `{open, due_today, overdue}` |
| `detail` | `task_id` | Task with checklist, comments, attachments |
| `create` | `title`, `description?`, `assignee_ids[]`, `due_at?`, `priority`, `attachment?`, `client_request_id?` | Created task. Role rules: who may assign to whom |
| `update_status` | `task_id`, `status`, `comment?` | Updated task |
| `comment` | `task_id`, `text`, `attachment?` | Updated activity list |
| `reassign` / `delete` (optional) | `task_id`, ... | |

Task object: `task_id, title, description, status, priority (low/normal/high), due_at, created_by{id,name}, assignees[], created_at, attachments[], is_overdue`.

Decision: can tasks and tickets be linked (a ticket that creates a task for maintenance)? If so add `ticket_id`.

### 5.6 Approvals (P1)

One inbox for anything a manager must approve (leave first, later purchase, ticket escalations).

```
POST index.php?page=approvals
```

| Action | Request | Response |
|---|---|---|
| `list` | `type?` (`leave`, ...), `status?` (`pending`/`done`), `pageNo`, `limit` | `data[]`: `{approval_id, type, title, requester{id,name,designation,photo}, summary, submitted_at, status}` and `counts{pending}` |
| `detail` | `approval_id` | Full detail, including the leave dates and the requester's balance |
| `decide` | `approval_id`, `decision` (`approve`/`reject`), `comment` (required on reject) | Updated item. Return `409` if already decided |

Visible only to roles with approval rights. The Menu `badge` should carry the pending count.

### 5.7 Notices / circulars (P1)

```
POST index.php?page=notices
```

| Action | Request | Response |
|---|---|---|
| `list` | `category?`, `unread_only?`, `pageNo`, `limit` | `data[]`: `{notice_id, title, summary, published_at, category, is_read, is_pinned, has_attachments}` |
| `detail` | `notice_id` | Full body (plain text or limited HTML; tell us which), attachments |
| `mark_read` | `notice_id` | |
| `acknowledge` (optional) | `notice_id` | For notices staff must confirm they read |

### 5.8 Ticket comments and activity (P1)

Both ticket modules have a detail screen that today shows only the current state.

- `tickets` and `manageTickets` → `action=comments` (`ticket_id`) returning `{comment_id, author{id,name,role}, text, attachment?, created_at}`.
- `action=add_comment` (`ticket_id`, `text`, `attachment?`).
- Include a status history (`status_name`, `changed_by`, `changed_at`) in the ticket detail.
- Push on each new comment or status change (section 6).

### 5.9 Documents and personal information (P1)

Today the Profile screen can only read. The sheets for "Personal information" and "Documents" are read-only.

| Action (`page=userProfile`) | Request | Response |
|---|---|---|
| `update_contact` | `phone?`, `email?`, `address?`, `emergency_contact?` | Updated profile. Tell us which fields staff may edit; HR fields stay read-only. |
| `update_photo` | `photo` (file, image only, max 5 MB) | New photo URL |
| `document_download` | `doc_id` | A **signed URL with a short life** (for example 5 minutes), or a streamed file |
| `document_upload` | `doc_type`, `doc_no?`, `issue_date?`, `expiry_date?`, `file` | Created document, status "pending HR review" |
| `document_types` | none | Types staff can upload, with whether issue and expiry dates are needed |

Document expiry alerts: today the app only reads `alert` and `alert_days`. If you want a push reminder before a visa or passport expires, that is a server job (section 6).

### 5.10 Notification preferences (P1)

The Profile screen has "Notification settings" as "Coming soon".

- `page=notificationSettings`, `action=get` → `{categories[]: {key, label, push, in_app}}`
- `action=update` → `{key, push, in_app}`, or a full replace.
- Categories to support at launch: tickets, attendance, leave, approvals, tasks, notices, events.
- Quiet hours (optional): `{from, to}`.

### 5.11 Staff directory (P1)

Menu → Staff (for principals, supervisors, admin, directors).

- `page=staff`, `action=list` (`search?`, `department?`, `designation?`, `pageNo`, `limit`) → `{id, name, designation, department, photo, phone?, email?, status}`
- `action=detail` (`staff_id`) → profile card and **today's attendance status** only if the role may see it.
- Respect privacy: which roles can see phone, email and HR data?

### 5.12 Timetable (P1)

- `page=timetable`, `action=my_week` (`week_start`) → periods: `{day, period_no, start_time, end_time, subject, class_key, section, room}`
- `action=today` → the same for today
- `action=substitutions` (optional) → covers assigned to me
- For non-teaching roles: confirm what they should see (shift pattern?).

### 5.13 Reports (P2)

For leadership. Please tell us which 5 or 6 reports matter. Suggested start:

- Staff attendance summary by school and date range
- Student attendance summary by class and date
- Open tickets by category and age
- Pending approvals by type

Shape: `page=reports`, `action=list` (available reports for the role) and `action=run` (`report_key`, `from`, `to`, `school_id?`) returning **summary numbers plus a short table** (not a full export). Large exports stay on the desktop.

### 5.14 Fees, Inventory, Calendar, Settings (P2)

These are on the Menu as "Soon" placeholders. We need a decision before design:

- **Fees:** who needs this on a phone (director, accounts)? Read-only summary (collected, outstanding by school) is the safe first step.
- **Inventory:** is this stock requests, or asset lists? Tie to tickets and approvals?
- **Calendar:** likely the same data as Events plus holidays and exams. We suggest merging into Events and dropping this tile.
- **Settings:** can stay local to the app (theme, language). A server call is only needed for notification preferences (5.10).

### 5.15 Face attendance and geofence (P2, held back)

The code for staff clock-in by face and location exists, but is **removed from the shipped menu and binary** for this release. When it returns, the app expects:

```
GET  {base}config/school-geofence        header: token
→ { "schoolName": "...", "centerLatitude": 25.2, "centerLongitude": 55.3, "radiusMeters": 150 }

POST {base}attendance/mark               header: token, multipart
employee_id, latitude, longitude, timestamp (UTC ISO 8601), image (selfie)
→ { "success": true, "matched": true, "attendanceId": "...", "markedAt": "ISO", "confidence": 0.93, "message": "..." }
```

Please confirm these two paths exist on the server and which of these are true: face matching runs on the server; the server re-checks the geofence (the phone's GPS can be spoofed); the same person cannot clock in twice within a set time; liveness or anti-spoofing is handled. If you want to ship this sooner, say so now.

---

## 6. Push notifications (P0)

**What the app does today**

- Gets an FCM token and sends it **only at login** (`fcm_token`).
- Shows a foreground notification, and routes a tapped notification using the data keys below.
- Increases a local unread count for the matching school and user if the push carries `school_code` and `admin_id`.

**Data keys the app understands now**

| Key | Meaning |
|---|---|
| `data_page` or `page` | Where to go. `/manageTicketDetailPage` or `/ticketDetailPage` open a ticket. Anything else opens the notification list. |
| `ticket_id` | Ticket to open (integer as text). |
| `school_code`, `admin_id` | Used to increase the unread badge for the right account. |
| `type`, `job_id` | Used by Careers. **Do not reuse**: a `type` starting with `careers`, or a `page` containing `career`, `job-detail` or `application`, is routed to the Careers app. |

**Requested contract for staff pushes**

```json
{
  "notification": { "title": "Leave approved", "body": "Your leave 3 to 5 Nov was approved." },
  "data": {
    "audience": "staff",
    "type": "leave_decision",
    "target_page": "leave",
    "target_id": "4821",
    "school_code": "demo",
    "admin_id": "112",
    "notification_id": "90331"
  }
}
```

- `audience: "staff"` so the app never confuses it with Careers.
- `type` values we will handle: `ticket_new`, `ticket_status`, `ticket_comment`, `leave_decision`, `approval_request`, `task_assigned`, `task_due`, `notice_new`, `event_reminder`, `document_expiry`, `attendance_alert`, `general`.
- `target_page` uses the same keys as the menu `page` field. `target_id` is the record to open.
- Include `notification_id` so opening the push marks it read.
- iOS: set `apns-push-type`, a badge count and `mutable-content` if you want rich notifications.
- Respect the user's notification preferences (5.10) and quiet hours before sending.
- Delete tokens that FCM reports as unregistered.

**Server-side triggers we expect**

New ticket for a manager, ticket status change, new comment, leave approved or rejected, approval needed, task assigned, task due soon and overdue, new notice, event reminder (default 30 min before), document expiring (30 and 7 days), absent without leave (for supervisors, optional).

---

## 7. Security checklist for the backend team

1. **Stop trusting `admin_id` from the client.** Derive the user from the token. (Today the app sends both.)
2. **Move the token out of the body** into a header, and make sure it is **not written to access logs**.
3. **Token expiry and revocation** (see 5.1). Revoke on logout, password change and account disable.
4. **NFC mapping has no authentication** (4.9). This must be closed before NFC ships.
5. **Role checks on every endpoint**, not just in the menu.
6. **Scope every query to the school** of the token. A staff token from school A must never read school B, even by guessing an ID.
7. **File downloads** use signed, expiring URLs. Profile photos and documents should not be guessable public URLs.
8. **Rate limit** login, forgot-password and OTP endpoints.
9. **Output encoding:** never print PHP warnings or notices into the JSON response.
10. **Minimise personal data.** Student DOB, religion, nationality and HR identity numbers are returned today. Confirm each is needed on a phone.
11. **TLS only**; HSTS on all school hosts.
12. **Audit log** for approvals, attendance edits, ticket status changes and document uploads, with the acting user and device.

---

## 8. Delivery plan

| Phase | Scope | Why |
|---|---|---|
| **0, now** | Confirm sections 4.1 to 4.9. Fix the zero-date and null issues in 4.3 and 4.2. Fix envelope and status codes. Close NFC auth. | The app is built against these today. |
| **1, launch blockers (P0)** | 5.1 session security, 5.2 dashboard, 5.3 events, 5.4 leave, 5.5 tasks, section 6 push contract | Home, the Events tab and the Tasks tab are visible to users now and show placeholders. |
| **2 (P1)** | 5.6 approvals, 5.7 notices, 5.8 ticket comments, 5.9 documents / personal info, 5.10 notification settings, 5.11 staff directory, 5.12 timetable, app version check | Completes the daily-use set. |
| **3 (P2)** | Reports, Fees, Inventory, Calendar, face attendance | Leadership and later-stage features. |

**How we work together:** for each endpoint we will agree the JSON example first, you publish it on the `demo` school host, then we build and test. The app only shows a module after its endpoint returns data, so partial delivery is safe. The menu `page` key is the switch: please do not add a key before we confirm the screen is in the build.

**Acceptance for each endpoint (please test before handing over):**

- Works for every role that should have it, and returns `403` for roles that should not.
- Returns `401` with an expired token and does not leak another school's data.
- Handles empty results with `status:true` and an empty list (not an error).
- Pagination works at the boundaries.
- Response time under 1 s for normal data on the school host.
- A sample response with real-looking data for the app team.

---

## 9. Open questions (we need answers before building)

1. Does the ERP already have **events, leave, tasks, notices, timetable and approvals** modules on the desktop? If yes, which tables or APIs? If not, who builds the desktop side?
2. **Roles:** please send the final role list and what each role should see in the app (a role by module table). The app expects at least principal, supervisor, teacher, nanny, maintenance, admin staff and director.
3. **Multi-school users:** can one person work at two schools? Today each school has its own host and its own token.
4. **Token model:** do you prefer short-lived token plus refresh token, or a long-lived token with server-side revoke?
5. **Leave policy:** who approves; how balances are calculated; are half days allowed.
6. **Events audience:** how is "who should see this event" decided?
7. **Time zones:** are all nine schools in the same zone? (Dates are sent with offset, so this is a check, not a blocker.)
8. **Attendance statuses:** the complete list of `stat` values and whether holidays are in the response (4.4).
9. **`classAttendance` marking:** please send the exact payload format your PHP expects for `attList` today, and whether it works (4.5).
10. **NFC and face attendance:** are they in the next release or later (4.9, 5.15)?
11. **Staging:** is there a test school host with realistic data for each role? We need one login per role.
12. **Rate limits and quotas** you impose on the API host, and any IP allow-listing.
13. **Versioning:** how will you tell old app versions that an endpoint changed? We suggest an `app_version` header on every call and a `min_supported_version` response from a config call.

---

## 10. App-side follow-ups that depend on these changes

For the backend team's awareness. The mobile team will do these.

- Send the token only in the header once 3.2 is agreed.
- Read the response of `classAttendance` marking and show real success or failure (today it always says "posted").
- Change the `attList` encoding to match 4.5.
- Call `logout` and `registerDevice` (5.1) and handle `401` globally.
- Handle empty or zero dates in profile data.
- Replace the three Home calls with `dashboard` (5.2) when it is ready.
- Show real Events, Leave and Tasks screens when their endpoints are ready; the screens are already designed.

---

## Appendix A. Page keys the app can open today

`userAttendance`, `tickets`, `manageTickets`, `classAttendance`, `students` (opened from class attendance), `nfcMapping`, `userProfile`.

## Appendix B. Proposed page keys for new modules

`dashboard`, `events`, `leave`, `tasks`, `approvals`, `notices`, `timetable`, `staff`, `reports`, `fees`, `inventory`, `notificationSettings`, `registerDevice`, `refreshToken`, `changePassword`, `forgotPassword`, `resetPassword`.

## Appendix C. Screen to endpoint map

| App screen | Endpoints it needs |
|---|---|
| Sign in | `login`, school list (the app reads this from the shared Careers `startup` endpoint; confirm it stays) |
| Home hero | `dashboard` (attendance), or `userAttendance` today |
| Home stat cards | `dashboard` (tasks, tickets, leave) |
| Home "Today's events" | `events` / `today` |
| Home "Quick access" | `userMenu` |
| Home "My tasks" | `tasks` / `list` |
| Menu | `userMenu` (with `badge`) |
| Events tab | `events` |
| Tasks tab | `tasks` |
| Profile | `userProfile`, `changePassword`, `notificationSettings`, `logout` |
| Notifications | `manageNotification` |
| My tickets, Manage tickets | `tickets`, `manageTickets`, ticket comments |
| Class attendance | `classAttendance` |
| Leave | `leave`, `approvals` (for approvers) |
| Notices | `notices` |
| NFC mapping | NFC transport endpoint |

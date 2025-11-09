# R.E.E.D. Bootie Hunter - Database Schema Documentation

## Overview

The application uses PostgreSQL as the database with ActiveRecord (Rails ORM) for data access. The schema consists of 13 core tables supporting user management, Bootie tracking, research, gamification, messaging, and AI prompt management.

---

## ⚠️ Connection Issues?

**If you can't connect to the database, see:**
- **[Database Connection Guide](./database/CONNECTION.md)** - Complete connection guide with SSL requirements
- **[Database Troubleshooting](./database/TROUBLESHOOTING.md)** - Common connection issues

**Quick Fix**: Render PostgreSQL requires SSL. Your `DATABASE_URL` must include `?sslmode=require`:
```
postgresql://user:pass@host/db?sslmode=require
```

---

## Database Tables

### users

Stores user accounts for Agents, Bootie Bosses, Admins, and Players.

**Columns**:
- `id` (bigint, primary key)
- `email` (string, not null, unique) - User email address
- `password_digest` (string, not null) - Hashed password (bcrypt)
- `name` (string, not null) - User display name
- `role` (string, not null, default: "agent") - User role: `agent`, `bootie_boss`, `admin`, `player`
- `phone_number` (string) - Optional phone number
- `avatar_url` (string) - Optional avatar image URL
- `active` (boolean, default: true) - Account active status
- `last_login_at` (datetime) - Last login timestamp
- `total_points` (integer, default: 0) - Total gamification points
- `total_items_scanned` (integer, default: 0) - Total Booties captured
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_users_on_email` (unique)
- `index_users_on_role`
- `index_users_on_total_points`

**Associations**:
- `has_many :booties`
- `has_many :conversations`
- `has_many :messages`
- `has_many :scores`
- `has_many :game_sessions`
- `has_many :leaderboards`
- `has_many :user_achievements`
- `has_many :achievements, through: :user_achievements`

**Validations**:
- Email: presence, uniqueness, format
- Name: presence
- Role: presence, inclusion in `['agent', 'bootie_boss', 'admin', 'player']`
- Password: minimum length 8 characters (on create/update)

---

### locations

Stores physical store locations.

**Columns**:
- `id` (bigint, primary key)
- `name` (string, not null) - Location name
- `address` (text) - Street address
- `city` (string) - City
- `state` (string) - State/Province
- `zip_code` (string) - Postal code
- `phone_number` (string) - Location phone number
- `email` (string) - Location email
- `latitude` (decimal, precision: 10, scale: 6) - GPS latitude
- `longitude` (decimal, precision: 10, scale: 6) - GPS longitude
- `notes` (text) - Additional notes
- `active` (boolean, default: true) - Location active status
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_locations_on_active`

**Associations**:
- `has_many :booties`

---

### booties

Core table storing captured items/inventory (Booties).

**Columns**:
- `id` (bigint, primary key)
- `user_id` (bigint, not null, foreign key to users) - User who captured the Bootie
- `location_id` (bigint, not null, foreign key to locations) - Location where Bootie was captured
- `title` (string, not null) - Item title
- `description` (text) - Item description
- `category` (string, not null) - Item category: `used_goods`, `antiques`, `electronics`, `collectibles`, `weaponry`, `artifacts`, `data_logs`, `miscellaneous`
- `status` (string, not null, default: "captured") - Workflow status: `captured`, `submitted`, `researching`, `researched`, `finalized`
- `recommended_bounty` (decimal, precision: 10, scale: 2) - AI-recommended price
- `final_bounty` (decimal, precision: 10, scale: 2) - Final price set by Bootie Boss
- `research_summary` (text) - Research summary text
- `research_reasoning` (text) - Research reasoning/justification
- `primary_image_url` (string) - Primary image URL
- `alternate_image_urls` (json, default: []) - Array of alternate image URLs
- `edited_image_urls` (json, default: []) - Array of AI-edited image URLs
- `square_product_id` (string) - Square catalog product ID (after finalization)
- `square_variation_id` (string) - Square catalog variation ID (after finalization)
- `finalized_at` (datetime) - Timestamp when finalized to Square
- `research_started_at` (datetime) - Timestamp when research started
- `research_completed_at` (datetime) - Timestamp when research completed
- `research_auto_triggered` (boolean, default: false) - Whether research was auto-triggered
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_booties_on_user_id`
- `index_booties_on_location_id`
- `index_booties_on_category`
- `index_booties_on_status`
- `index_booties_on_created_at`
- `index_booties_on_square_product_id`

**Associations**:
- `belongs_to :user`
- `belongs_to :location`
- `has_many :research_logs, dependent: :destroy`
- `has_many :grounding_sources, dependent: :destroy`
- `has_many :scores, dependent: :nullify`

**Validations**:
- Title: presence
- Category: presence, inclusion in valid categories
- Status: presence, inclusion in valid statuses

**Status Workflow**:
1. `captured` - Initial capture
2. `submitted` - Submitted for research
3. `researching` - Research in progress
4. `researched` - Research completed
5. `finalized` - Published to Square

---

### research_logs

Stores detailed research history and process logs.

**Columns**:
- `id` (bigint, primary key)
- `bootie_id` (bigint, not null, foreign key to booties) - Associated Bootie
- `query` (text) - Research query used
- `response` (text) - Research response/result
- `research_method` (string) - Method used (e.g., "gemini_google_search", "discogs_search")
- `raw_data` (text) - Raw research data (JSON string)
- `success` (boolean, default: true) - Whether research succeeded
- `error_message` (text) - Error message if research failed
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_research_logs_on_bootie_id`
- `index_research_logs_on_created_at`

**Associations**:
- `belongs_to :bootie`
- `has_many :grounding_sources`

---

### grounding_sources

Stores research source citations (URLs, titles, snippets).

**Columns**:
- `id` (bigint, primary key)
- `bootie_id` (bigint, not null, foreign key to booties) - Associated Bootie
- `research_log_id` (bigint, foreign key to research_logs) - Associated research log (optional)
- `title` (string, not null) - Source title
- `url` (text, not null) - Source URL
- `snippet` (text) - Source snippet/excerpt
- `source_type` (string) - Type of source (e.g., "google_search", "discogs")
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_grounding_sources_on_bootie_id`
- `index_grounding_sources_on_research_log_id`

**Associations**:
- `belongs_to :bootie`
- `belongs_to :research_log, optional: true`

---

### conversations

Stores conversation threads (for messaging system).

**Columns**:
- `id` (bigint, primary key)
- `user_id` (bigint, not null, foreign key to users) - Conversation owner
- `conversation_type` (string, not null) - Type: `reed`, `user_to_user`, `boss_to_agent`, `admin_broadcast`
- `participant_type` (string) - Type of participant (e.g., "user", "system")
- `participant_user_id` (bigint, foreign key to users) - Other participant user (if applicable)
- `context_summary` (text) - Summary of conversation context
- `last_message_at` (datetime) - Timestamp of last message
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_conversations_on_user_id`
- `index_conversations_on_participant_user_id`
- `index_conversations_on_last_message_at`

**Associations**:
- `belongs_to :user`
- `belongs_to :participant_user, class_name: 'User', optional: true`
- `has_many :messages`

---

### messages

Stores individual messages within conversations.

**Columns**:
- `id` (bigint, primary key)
- `conversation_id` (bigint, not null, foreign key to conversations) - Parent conversation
- `user_id` (bigint, foreign key to users) - User who sent the message (null for system messages)
- `sender_type` (string, not null) - Sender type: `user`, `reed`, `system`
- `content` (text, not null) - Message content
- `message_type` (string, not null, default: "text") - Message type: `text`, `image`, `system_notification`
- `metadata` (json) - Additional message metadata
- `read` (boolean, default: false) - Whether message has been read
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_messages_on_conversation_id`
- `index_messages_on_conversation_id_and_read`
- `index_messages_on_created_at`

**Associations**:
- `belongs_to :conversation`
- `belongs_to :user, optional: true`

---

### scores

Stores individual scoring events for gamification.

**Columns**:
- `id` (bigint, primary key)
- `user_id` (bigint, not null, foreign key to users) - User who earned the score
- `action_type` (string, not null) - Type of action: `bootie_captured`, `bootie_finalized`, `tag_found`, `scour_completed`, etc.
- `points` (integer, not null) - Points awarded
- `bootie_id` (bigint, foreign key to booties) - Associated Bootie (if applicable)
- `game_session_id` (bigint, foreign key to game_sessions) - Associated game session (if applicable)
- `metadata` (text) - Additional metadata (JSON string)
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_scores_on_user_id`
- `index_scores_on_bootie_id`
- `index_scores_on_game_session_id`
- `index_scores_on_action_type`
- `index_scores_on_created_at`

**Associations**:
- `belongs_to :user`
- `belongs_to :bootie, optional: true`
- `belongs_to :game_session, optional: true`

---

### leaderboards

Stores leaderboard rankings by period.

**Columns**:
- `id` (bigint, primary key)
- `user_id` (bigint, not null, foreign key to users) - User on leaderboard
- `period_type` (string, not null) - Period type: `daily`, `weekly`, `monthly`, `overall`
- `period_date` (date) - Period date (null for overall)
- `points` (integer, default: 0) - Points for this period
- `rank` (integer) - Rank position
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_leaderboards_on_user_id`
- `index_leaderboards_on_period_type_period_date_points` (composite)
- `index_leaderboards_on_period_type_period_date_rank` (composite)

**Associations**:
- `belongs_to :user`

---

### achievements

Stores achievement/badge definitions.

**Columns**:
- `id` (bigint, primary key)
- `name` (string, not null) - Achievement name
- `description` (text) - Achievement description
- `badge_icon_url` (string) - Badge icon image URL
- `achievement_type` (string) - Type of achievement
- `points_required` (integer) - Points required to earn
- `active` (boolean, default: true) - Whether achievement is active
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_achievements_on_achievement_type`
- `index_achievements_on_active`

**Associations**:
- `has_many :user_achievements`
- `has_many :users, through: :user_achievements`

---

### user_achievements

Junction table linking users to achievements they've earned.

**Columns**:
- `id` (bigint, primary key)
- `user_id` (bigint, not null, foreign key to users) - User who earned the achievement
- `achievement_id` (bigint, not null, foreign key to achievements) - Achievement earned
- `earned_at` (datetime, not null) - Timestamp when earned
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_user_achievements_on_user_id_and_achievement_id` (unique composite)

**Associations**:
- `belongs_to :user`
- `belongs_to :achievement`

---

### game_sessions

Stores game mode sessions (S.C.O.U.R., L.O.C.U.S., T.A.G.).

**Columns**:
- `id` (bigint, primary key)
- `user_id` (bigint, not null, foreign key to users) - User playing the session
- `game_type` (string, not null) - Game type: `scour`, `locus`, `tag`
- `status` (string, not null, default: "active") - Session status: `active`, `completed`, `abandoned`
- `started_at` (datetime, not null) - Session start timestamp
- `completed_at` (datetime) - Session completion timestamp
- `score` (integer, default: 0) - Session score
- `items_processed` (integer, default: 0) - Number of items processed
- `time_seconds` (integer) - Duration in seconds
- `metadata` (json) - Additional session metadata
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_game_sessions_on_user_id`
- `index_game_sessions_on_game_type_and_status` (composite)
- `index_game_sessions_on_started_at`

**Associations**:
- `belongs_to :user`
- `has_many :scores`

---

### prompts

Stores AI prompts and system instructions for the R.E.E.D. application. Supports multiple categories including system instructions, image processing, research, chat, game modes, and tool functions.

**Columns**:
- `id` (bigint, primary key)
- `category` (string, not null) - Prompt category: `system_instructions`, `image_processing`, `research`, `chat`, `game_modes`, `tool_functions`
- `name` (string, not null) - Unique identifier/name for the prompt within its category
- `model` (string, not null) - Gemini model name (e.g., `gemini-2.5-flash`, `gemini-flash-lite-latest`)
- `prompt_text` (text, not null) - The actual prompt text
- `description` (text) - Description of what this prompt does
- `use_case` (string) - What this prompt is used for
- `metadata` (json) - Additional metadata (expected_output, tools, arguments, etc.)
- `active` (boolean, default: true, not null) - Whether this prompt is currently active
- `version` (integer, default: 1, not null) - Version number for tracking changes
- `prompt_type` (string) - Type: `system_instruction`, `prompt_template`, `tool_function`
- `sort_order` (integer, default: 0) - For ordering prompts in UI
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes**:
- `index_prompts_on_category`
- `index_prompts_on_name`
- `index_prompts_on_category_and_name` (unique, composite)
- `index_prompts_on_active`
- `index_prompts_on_prompt_type`

**Validations**:
- Category: presence, inclusion in valid categories
- Name: presence, uniqueness within category
- Model: presence
- Prompt text: presence
- Prompt type: inclusion in `['system_instruction', 'prompt_template', 'tool_function']` (if present)

**Notes**:
- Prompts are versioned - version increments automatically when prompt_text changes
- Only active prompts are available for use in the application
- Category and name together form a unique constraint
- Metadata is stored as JSON for flexibility

---

## Relationships Diagram

```
users
  ├─► booties (1:N)
  ├─► conversations (1:N)
  ├─► messages (1:N)
  ├─► scores (1:N)
  ├─► game_sessions (1:N)
  ├─► leaderboards (1:N)
  └─► user_achievements (1:N) ──► achievements (N:1)

locations
  └─► booties (1:N)

booties
  ├─► research_logs (1:N)
  ├─► grounding_sources (1:N)
  └─► scores (1:N)

research_logs
  └─► grounding_sources (1:N)

conversations
  └─► messages (1:N)

game_sessions
  └─► scores (1:N)

prompts
  (standalone table, no relationships)
```

## Key Constraints

1. **Foreign Keys**: All foreign key relationships are enforced at the database level
2. **Unique Constraints**: 
   - `users.email` must be unique
   - `user_achievements(user_id, achievement_id)` must be unique (user can only earn achievement once)
   - `prompts(category, name)` must be unique (prompt name must be unique within its category)
3. **Not Null Constraints**: Critical fields like `title`, `status`, `category` are required
4. **Default Values**: Status fields have sensible defaults (e.g., `status="captured"` for booties, `active=true` for prompts)

## Indexes for Performance

Indexes are created on:
- Foreign keys (for join performance)
- Frequently filtered columns (`status`, `category`, `role`)
- Sort columns (`created_at`, `last_message_at`)
- Composite indexes for common query patterns (leaderboards, game sessions)

## Data Types

- **Strings**: Used for short text (titles, names, codes)
- **Text**: Used for longer content (descriptions, summaries)
- **JSON**: Used for flexible arrays/objects (image URLs, metadata)
- **Decimal**: Used for monetary values (bounty prices) with precision
- **Boolean**: Used for flags and status indicators
- **Datetime**: Used for timestamps

---

*For model code and validations, see `backend/app/models/`. For migrations, see `backend/db/migrate/`.*


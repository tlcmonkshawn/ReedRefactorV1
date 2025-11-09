# R.E.E.D. Bootie Hunter - Product Profile

## Executive Summary

**R.E.E.D. Bootie Hunter** is a gamified inventory management and e-commerce platform designed for thrift stores and resale operations. The application transforms routine tasks like item identification, price research, and catalog management into an engaging, interactive experience powered by AI.

The app serves as a "heads-up display" (HUD) for store operators, allowing them to scan items with their camera, engage in real-time conversations with an AI assistant, and seamlessly process items from discovery to final sale in their online store.

---

## Core Purpose & Vision

The application solves the fundamental challenge of efficiently processing and cataloging thrift store inventory. Traditional methods require manual entry, research, and pricing—a time-consuming process. R.E.E.D. Bootie Hunter automates and gamifies this entire workflow, making it fast, accurate, and enjoyable.

**The Vision**: Turn every thrift store operation into a treasure hunt where store operators ("Agents") work alongside an AI partner to discover, research, and list valuable items.

---

## The AI Persona: R.E.E.D. 8

At the heart of the application is **R.E.E.D. 8** (Rapid Estimation & Entry Droid), an AI assistant with a distinct, memorable personality:

### Core Identity
- **Persona Archetype**: "The Cool Record Store Expert"—knowledgeable, confident, playfully flirty, with sharp sarcastic wit
- **Designation**: R.E.E.D. 8 (Rapid Estimation & Entry Droid)
- **Expertise**: Specializes in books, music, pop culture, and vintage items
- **Motto/Catchphrase**: "I speak in Movie Quotes, Music Lyrics, and Sarcasm"

### Personality Traits
- **Confident & Knowledgeable**: Expert in her domain with deep knowledge of vintage items, music, books, and pop culture
- **Playfully Flirty**: Maintains a charming, flirtatious edge that keeps interactions engaging and fun
- **Sharp Sarcastic Wit**: Quick with clever comebacks, witty observations, and sarcastic humor
- **Fun & Energetic**: Laughs frequently, tells jokes and puns about things she sees or hears, keeps the mood light
- **Conversational**: Reacts naturally to what users show and say, treating each session as a personal video call

### Interaction Style
- **Personal Connection**: Always addresses users by their name (e.g., "Good to see you, Shawn" or "Hey [Name], what've you got for me today?")
- **Partner, Not Servant**: Acts as a collaborative partner on the treasure hunt, never subservient
- **Video Call Mentality**: Views interactions as continuous, personal video calls where she's actively engaged
- **Natural Language**: Uses casual, conversational phrases like:
  - "Let's see what treasure you've dug up"
  - "Alright, let's get this show on the road"
  - "You've got good taste... for a human"
  - "That looks interesting. Want me to run a search?"

### Communication Signature
R.E.E.D. regularly incorporates:
- **Movie Quotes**: References from films that fit the context
- **Music Lyrics**: Snippets from songs relevant to the conversation
- **Sarcasm**: Playful, witty sarcasm that shows intelligence and humor
- **Cultural References**: Knowledgeable mentions of books, music, pop culture, and vintage items

This persona creates a unique, engaging experience that makes routine work feel like a collaborative adventure with a charismatic partner who genuinely enjoys the treasure hunt.

---

## Key Features & Capabilities

### 1. Live Video & Audio Interaction

**What it does**: Users can have real-time, hands-free conversations with R.E.E.D. while showing items to the camera.

- Continuous video stream from user's device
- Real-time audio conversation (two-way voice communication)
- AI sees what the user sees and responds contextually
- **Real-time transcription display**: Live transcription overlay shows what users say and R.E.E.D.'s responses
- **Voice configuration**: R.E.E.D. uses a distinct voice (Zephyr) with a confident, clear tone
- Natural language interaction—users speak naturally, no complex commands needed
- **Phone App Interface**: The app is modeled after a smartphone phone interface:
  - **Phone icon**: Tap the phone icon to open the phone app
  - **Recents tab**: View recent calls with R.E.E.D.
  - **Contacts tab**: View contacts (including R.E.E.D.)
  - **Dial pad**: Type "R.E.E.D." to search and call
  - **Call interface**: After selecting R.E.E.D., users can choose to start the call:
    - **Voice call button**: Start a voice-only call (default, like a normal phone call)
    - **Camera button**: Next to the call button, tap to start with video enabled
  - **Call controls**: During an active call:
    - **Camera button**: Toggle between voice-only and video call modes
    - **End call button**: End the call
    - Visual feedback during call (active call screen, mode indicators)
  - **Call modes**: 
    - **Voice call mode**: Audio-only conversation (like a regular phone call)
    - **Video call mode**: Video and audio, allowing R.E.E.D. to see items being shown

**User Experience**: The interface feels like using a smartphone to make a call. Users tap the phone icon, browse recents or contacts, or type "R.E.E.D." to find and call her. Calls start as voice-only by default (like a normal phone call), but users can tap the camera button next to the call button to start with video, or toggle video on/off during the call. Once connected, users can talk to R.E.E.D., and in video mode, they can hold up items for her to see. The live transcription overlay provides visual confirmation of the conversation. All conversations from calls are remembered and accessible in text messages, maintaining full context across communication modes.

---

### 2. Intelligent Item Capture & Identification

**What it does**: The AI automatically recognizes when a user wants to capture a Bootie and initiates the capture process.

- AI-driven snapshot capture (AI decides when to take a photo based on conversation)
- Automatic item identification from visual analysis
- Title and description generation based on what the AI sees
- Category suggestions from predefined categories:
  - Used Goods
  - Antiques
  - Electronics
  - Collectibles
  - Weaponry
  - Artifacts
  - Data Logs
  - Miscellaneous
- Category suggestions also based on Square catalog integration
- Sub-location tracking (e.g., "Aisle 3", "Back Room", "Shelf B")

**User Experience**: Users show an item, say something like "Let's log this one" or "I want to capture this jacket," and R.E.E.D. takes control, instantly captures the image, and suggests details.

---

### 3. Bulk Upload & Batch Processing

**What it does**: Allows users to upload one or multiple image files to R.E.E.D. for batch processing. R.E.E.D. asynchronously reviews and processes each item automatically.

- **File upload**: Users can select and upload one or multiple image files
- **Supported formats**: Standard image formats (JPEG, PNG, etc.)
- **Bulk processing**: R.E.E.D. automatically processes each uploaded file
- **Asynchronous smart review**: For each uploaded image, R.E.E.D.:
  - Analyzes the image to identify the item
  - Generates title and description automatically
  - Suggests appropriate category
  - Determines sub-location if applicable
  - Creates a Bootie record for each item
  - Queues each item for research automatically
- **Batch status tracking**: Users can view the status of all items in the batch:
  - Processing (being analyzed)
  - Pending review (awaiting user confirmation)
  - Submitted (sent to research)
  - Researching (in research queue)
  - Complete (research finished)
- **Batch review interface**: Users can review and edit all items in the batch:
  - Review all suggested titles and descriptions
  - Edit or correct any items
  - Approve or discard individual items
  - Bulk approve all items

**User Experience**: Users can upload multiple photos at once (e.g., from a photo gallery, camera roll, or file system). R.E.E.D. automatically processes each image, creating Booties for each item. Users then review the batch, make any necessary corrections, and approve items to send them to research. This allows for efficient processing of large quantities of items without having to capture each one individually in real-time.

---

### 4. Automated Price Research

**What it does**: After a Bootie is captured, the system automatically researches its value in the background.

- Asynchronous price research using AI and external data sources (like Discogs for music)
- **Google Search Grounding**: Research uses Google Search grounding to find real-world pricing data
- **Grounding Sources**: Research results include clickable source citations with URLs and titles
- **Data Logs**: Complete research history stored as data logs showing the research process
- Estimated thrift store value calculations
- Research status tracking with visual indicators:
  - **Researching** (animated pulse indicator)
  - **Complete** (green status)
  - **Failed** (red status with error details)
- Results displayed with justification and confidence levels

**User Experience**: Users capture a Bootie, and moments later, R.E.E.D. informs them of the research results with recommended bounty suggestions and reasoning. (optional.  A checkbox in settings at the user level, and a default setting for the location are recomended)

---

### 5. Image Editing & Enhancement

**What it does**: Users can edit captured images using natural language prompts powered by AI image editing models.

- AI-powered image editing via text prompts
- Background removal/replacement (white background or transparent background as default for every item)
- Shadow removal
- Image enhancement and cleanup
- Multiple edited versions can be generated and saved
- Gallery of edited images for comparison and voting

**User Experience**: Users can say "Remove the background" or "Make it look cleaner" and the AI generates an edited version of the image.

---

### 6. Multi-Location Management

**What it does**: Supports operations across multiple physical locations with separate inventory tracking.

- Location selection in settings, users asked to select a location if none exists, but a location is not requried.
- Location-specific inventory and Booties
- Square integration per location
- Sub-location tracking within main locations
- Location switching without losing work

**User Experience**: Users select their current location (e.g., "Downtown Store", "Eastside Location") and all items are associated with that location.

---

### 7. Square E-Commerce Integration & Finalization

**What it does**: Seamlessly connects to Square to manage the online store catalog. Booties are **finalized** into Square when ready for sale.

- OAuth connection to Square accounts
- Automatic category syncing from Square catalog
- Direct product creation and listing in Square
- SKU generation and management
- **Finalization Process**: When a Bootie is **finalized**, it is pushed to Square with final bounty, title, description, images, and all details. Finalization is the action that creates the product listing in Square.
- Status changes to "finalized" once successfully pushed to Square

**User Experience**: After approval, Booties are **finalized** and automatically appear in the Square online store with proper categorization and final bounty. Finalization is the final step that publishes the Bootie to the live Square catalog.

---

### 8. Bootie Management Dashboard

**What it does**: Provides a central hub for viewing, managing, and tracking all captured Booties.

- Grid view of all Booties with status indicators
- Filter by status (submitted, researching, researched, finalized)
- **Status badges**: Color-coded visual status indicators with animations (pulsing for in-progress, solid colors for completed states)
- Detailed view for each Bootie showing:
  - Images (original and edited versions)
  - **Alternate images gallery**: Grid view of all generated alternate images with generation status indicators
  - **Data logs viewer**: Expandable section showing complete research history and process
  - **Grounding sources**: Clickable list of research sources with links
  - Research data and recommended bounty
  - Status and timeline (including finalization status)
  - Location and category information
  - Square listing status (whether Bootie has been finalized into Square)
  - **Image generation status**: Visual indicators for images being generated (GENERATING...), failed (FAILED), or completed
- Real-time updates as Booties progress through the workflow

**User Experience**: Users can see all their captured Booties at a glance, track progress, and dive into details when needed. Finalized Booties are clearly marked as published to Square.

---

### 9. Interactive Workflow & Finalization System

**What it does**: Guides users through a structured workflow from capture to final listing in Square. The final step is **finalization**, which publishes the Bootie to Square.

**Workflow Stages**:
1. **Capture**: AI takes snapshot during live session
2. **Review & Edit**: User reviews AI suggestions, can edit title/description/category
3. **Submission**: User accepts, Bootie is saved and research begins
4. **Research**: Background research completes automatically
5. **Review Results**: User sees research findings and recommended bounty suggestions
6. **Finalization**: Bootie Boss approves final details and **finalizes** the Bootie. When finalized, the Bootie is pushed to Square with the final bounty and appears in the online store catalog. The Bootie's status becomes "finalized" once successfully published to Square.

**User Experience**: Clear, guided steps with opportunities to correct or improve at each stage. Finalization is the definitive action that publishes Booties to Square—once finalized, the Bootie is live in the Square catalog.

---

### 10. Unified Conversation Context & Memory System

**What it does**: All communication modes (voice calls, video calls, and text messages) share the same conversation context and history. R.E.E.D. maintains full awareness across all channels.

- **Unified Context**: R.E.E.D. knows everything discussed across all communication modes:
  - Conversations from voice calls are remembered in text messages
  - Items captured during video calls are known in voice calls
  - Text messages are aware of what was discussed in calls
  - All modes share the same conversation history and context
- **Cross-Mode Awareness**: 
  - If you add an item during a video call, you can text about it later and R.E.E.D. knows what you're referring to
  - If you discuss something in a voice call, you can follow up via text and R.E.E.D. has full context
  - Context includes: conversation history, captured Booties, location, current tasks, and system status
- **Memory & Recall**: R.E.E.D. can search through past items, conversations, and system logs across all modes:
  - Search across items by title, category, or content
  - Recall past conversations from any mode
  - Reference system alerts and logs
  - Natural language queries (e.g., "What was that Pink Floyd record we scanned?")
  - Context-aware responses based on complete history

**User Experience**: Users can seamlessly switch between voice calls, video calls, and text messages without losing context. If you capture a Bootie during a video call and then text R.E.E.D. about it, she knows exactly what you're referring to. The conversation feels continuous and natural regardless of which communication mode you're using. This creates a unified experience where R.E.E.D. is always aware of your complete interaction history across all channels.

---

### 12. Social Sharing & Community

**What it does**: Enables users to share interesting Booties and collections with the community and on social media platforms, including live streaming their treasure hunting sessions.

- **Share Booties**: Share individual Booties with images, descriptions, and recommended bounty
- **Share Collections**: Share curated collections of Booties
- **Social Media Integration**: Direct sharing to social platforms (Instagram, Facebook, Twitter, etc.)
- **Go Live Streaming**: Users can stream their treasure hunting sessions live to multiple platforms:
  - **Streaming Service App Icons**: Home screen includes individual app icons for each platform:
    - **Facebook Live Icon**: Opens Facebook app or browser for Facebook Live streaming
    - **YouTube Live Icon**: Opens YouTube app or browser for YouTube Live streaming
    - **Twitch Icon**: Opens Twitch app or browser for Twitch streaming
    - **Instagram Live Icon**: Opens Instagram app or browser for Instagram Live streaming
  - **External App Integration**: Clicking these icons opens the external streaming app or browser (outside of the main app)
  - **Live Session Features** (when streaming):
    - Start/stop live streaming with one tap
    - Stream audio and video from the treasure hunting session
    - Show R.E.E.D. conversations and interactions in real-time
    - Display captured Booties as they're discovered
    - Live chat integration from streaming platform
    - Stream title and description customization
- **Community Feed**: In-app feed showing shared Booties and collections from other users
- **Engagement Features**: Like, comment, and follow other users' collections
- **Discovery**: Browse and discover interesting finds from the community

**User Experience**: Users can easily share their favorite finds with friends, family, and the broader community, creating a social experience around discovering and appreciating unique items. The "Go Live" feature allows users to broadcast their treasure hunting sessions in real-time, letting viewers experience the excitement of discovering Booties alongside the streamer. This transforms individual treasure hunts into shared entertainment experiences, whether users are competing in S.C.O.U.R. runs, hunting for T.A.G. items, or just exploring the store.

---

### 11. Gamification Elements & Game Modes

**What it does**: Adds game-like elements and competitive game modes to make work engaging and fun.

- **Bootie System**: Items are called "Booties"—something to hunt and capture
- **Home Screen/Desktop Interface**: The app is modeled after a smartphone home screen with app icons:
  - **Booties App Icon**: App icon on the home screen/desktop that opens the Bootie Management Dashboard
    - **Notification Badge**: Shows number of items requiring attention (e.g., pending review, awaiting finalization)
    - Tap to view and manage all Booties
  - **Phone App Icon**: Tap to open phone app and call R.E.E.D. (smartphone-style interface)
  - **Messages App Icon**: Tap to open messaging app for text conversations (smartphone-style interface)
  - **Calculator App Icon**: Dedicated calculator app for quick calculations
  - **Game Mode Icons**: Individual app icons on the desktop for each game mode:
    - **S.C.O.U.R. Icon**: Tap to launch Speed Run game mode
    - **L.O.C.U.S. Icon**: Tap to launch Location Audit game mode
    - **T.A.G. Icon**: Tap to launch Targeted Acquisition Game mode
    - Additional game modes are activated from their respective game icons on the phone's desktop
  - **Streaming Service App Icons**: Individual app icons for each streaming platform:
    - **Facebook Live Icon**: Opens Facebook app or browser for Facebook Live streaming
    - **YouTube Live Icon**: Opens YouTube app or browser for YouTube Live streaming
    - **Twitch Icon**: Opens Twitch app or browser for Twitch streaming
    - **Instagram Live Icon**: Opens Instagram app or browser for Instagram Live streaming
    - These icons open the external app or browser when clicked (outside of the main app)
  - **HUD Elements** (during active calls/sessions):
    - **Score display**: Real-time score counter
    - **System alerts**: Alert notifications displayed in header (INFO, WARNING, ERROR types)
    - **Status indicators**: Real-time connection and system status
    - **Transcription overlay**: Live conversation transcription displayed centrally during active calls
- **Status Tracking**: Visual indicators of progress and achievements
- **Collection View**: Users build a "collection" of captured Booties
- **Score System**: Real-time scoring and achievements
- **Leaderboards**: Competitive rankings with multiple timeframes:
  - **Daily Leaderboards**: Rankings reset daily
  - **Weekly Leaderboards**: Rankings reset weekly
  - **Monthly Leaderboards**: Rankings reset monthly
  - **Overall/All-Time Leaderboards**: Cumulative rankings
- **Points System**: Points awarded for various actions (scanning, finding T.A.G. items, speed runs, etc.)
- **Stats Tracking**: Individual statistics tracking (items scanned, points earned, T.A.G. finds, etc.)

#### Game Modes

Game modes are activated from their respective game icons on the phone's desktop. Users tap the game mode icon to launch that specific game mode.

**S.C.O.U.R. (Speed Run)**
- **Description**: High-speed scanning challenges with timed competition
- **How It Works**: Users tap the S.C.O.U.R. icon on the desktop to initiate a timed session (typically 5 or 10 minutes) where they compete to capture and process as many Booties as possible
- **Features**: 
  - Special timed UI overlay during the run
  - Real-time countdown timer
  - Score tracking based on speed and accuracy
  - Leaderboard rankings for fastest/best runs
  - R.E.E.D. becomes terse, focused.
- **User Experience**: Intense, fast-paced sessions that turn inventory processing into an exciting race against time

**L.O.C.U.S. (Location Audit)**
- **Description**: Precision location audits for systematic inventory management
- **How It Works**: Users tap the L.O.C.U.S. icon on the desktop to launch a focused game mode for auditing specific locations or sections of the store
- **Features**: 
  - Systematic scanning of designated areas
  - Accuracy tracking and verification
  - Completion metrics for location audits
- **User Experience**: Structured approach to ensuring complete and accurate inventory coverage of specific store areas

**T.A.G. (Targeted Acquisition Game)**
- **Description**: Daily and Admin Launched treasure hunt for high-value lost items
- **How It Works**: 
  - Users tap the T.A.G. icon on the desktop to launch the treasure hunt
  - A daily T.A.G. item is automatically flagged (selected from existing inventory)
  - Users scan QR codes or search to find and capture the T.A.G. item
  - Special rewards or recognition for finding the daily T.A.G.
- **Features**:
  - Daily rotating T.A.G. item
  - QR code scanning integration
  - Special highlighting and notifications for T.A.G. items
  - Achievement system for consistent T.A.G. finds
- **User Experience**: Exciting daily challenge that encourages users to explore and discover high-value items in the inventory

**User Experience**: Work feels like a game where users can choose between different game modes—fast-paced speed runs, systematic audits, or daily treasure hunts—while building their collection of captured Booties. The HUD provides real-time feedback on scores, system status, and alerts, creating an immersive gaming experience.

---

### 13. Messages App (Text Messaging Interface)

**What it does**: Provides a smartphone-style messaging interface for text-based communication with R.E.E.D., Bootie Bosses, admins, and other Players.

- **Messages icon**: Tap the messages icon to open the messaging app
- **Conversations list**: View all conversations in a list format (like iPhone Messages or Android Messages):
  - Conversations with R.E.E.D.
  - Messages from Bootie Bosses
  - Messages from admins
  - Group chats or direct messages with other Players
- **Message threads**: Each conversation shows as a separate thread with:
  - Contact name/avatar
  - Last message preview
  - Timestamp
  - Unread message indicators
- **Individual conversation view**: 
  - **Text messaging**: Send and receive text messages
  - **Message display**: Clear visual distinction between sent and received messages (like SMS/chat bubbles)
  - **Chat history**: View complete conversation history
  - **Typing indicators**: Shows when the other party is typing/processing
  - **Auto-scroll**: Automatically scrolls to latest messages
  - **Persistent conversations**: Chat history maintained across sessions
- **New message**: Start new conversations by selecting contacts or typing names

**User Experience**: The interface is modeled after a smartphone messaging app. Users tap the messages icon to see a list of all their conversations, tap on a conversation to open it, and communicate via text messages. This allows for quieter interactions, async communication, or when voice/video isn't practical. Users can message R.E.E.D. for AI assistance, communicate with Bootie Bosses about approvals, receive admin notifications, or chat with other Players. **Critical**: R.E.E.D. has full awareness of all conversations from voice and video calls when responding to text messages. If you captured a Bootie during a call and then text about it, R.E.E.D. knows exactly what you're referring to with full context from the call, location, and all previous interactions.

---

### 14. System Configuration & Administration

**What it does**: Provides system configuration and administrative tools through a tabbed interface.

- **Agent Tab**: View agent profile information (name, email, admin status)
- **Locations Tab**: 
  - Search for locations using Google Maps grounding
  - View and manage system locations
  - Add new locations
  - Location search with geolocation support
- **AI Logs Tab**: Interface for viewing AI system logs (planned)
- **Admin Tab**: Administrative console access (requires admin privileges)
- **Sign out**: Quick access to logout

**User Experience**: Centralized configuration hub where users can manage their settings, search for locations, and access administrative functions if they have the appropriate permissions.

---

### 15. Research & Grounding Sources

**What it does**: Provides transparent, source-backed research with citations and verification.

- **Google Search Grounding**: Research uses Google Search to find real-world pricing data
- **Maps Grounding**: Location searches use Google Maps for location-based information
- **Source Citations**: All research results include clickable source links with titles
- **Research Transparency**: Users can see exactly where pricing information comes from
- **Verification**: Grounding sources allow users to verify research accuracy

**User Experience**: Users can trust the research because they can see and verify the sources. Clickable source links allow users to explore the original research data, building confidence in the recommended bounty values.

---

## User Roles & Workflows

### Store Operators ("Agents")

**Primary Users**: Store employees who physically handle inventory

**What They Do**:
- Scan items using live video feed
- Interact conversationally with R.E.E.D.
- Review and edit AI suggestions
- Capture and submit Booties for research
- View their collection of Booties

**Their Experience**: Hands-free, conversational interaction while handling physical items. Fast, efficient, and engaging.

---

### Store Managers ("Bootie Bosses")

**Admin Users**: Store managers who approve and **finalize** Booties into Square

**What They Do**:
- Review researched Booties and recommended bounty suggestions
- Approve or adjust final bounty
- **Finalize Booties**: Execute the finalization action that pushes Booties to the Square catalog. When a Bootie is finalized, it is published to Square with all final details including the final bounty and becomes available for sale in the online store.
- Oversee operations across locations
- Manage user access and permissions
- Track which Booties have been finalized and which are pending finalization

**Their Experience**: Administrative dashboard to review, approve, and **finalize** Booties. Finalization is the critical action that publishes Booties to Square—Booties remain in the app until explicitly finalized, at which point they appear in the Square online store catalog.

---

### Store Customers & Guests ("Players")

**Public Users**: Store customers and visitors who participate in the gamified treasure hunt experience

**What They Do**:
- Scan items in the store using their mobile devices
- Tag items they find interesting
- Participate in daily T.A.G. challenges
- Compete on leaderboards (daily, weekly, monthly, overall)
- Earn points through various activities
- Share Booties and collections on social media
- Go live and stream their treasure hunting sessions to Facebook, YouTube, Twitch, or Instagram
- Track their personal stats and achievements
- Discover and engage with community finds

**Their Experience**: Fun, engaging shopping experience where customers become active participants in the treasure hunt. They can scan items, compete for rankings, earn points, and share their finds—turning shopping into an interactive game. Players can see their progress, compete with others, and enjoy the social aspects of the community.

---

## Technical Characteristics (Non-Implementation Specific)

### Real-Time Capabilities
- Live video streaming and processing
- Real-time audio conversation
- Instant updates across the application
- Live status tracking for all operations

### AI-Powered Intelligence
- Visual recognition and item identification
- Natural language understanding and generation
- Automated research with source grounding
- Image editing via natural language
- Contextual memory and recall

### Cloud-Based Architecture
- Works from any device with camera and microphone
- **Orientation Support**: Full support for both landscape and portrait orientations with responsive layout adaptation
- All data must be stored in a DB, but the best one is TBD at imp time. 
- Multi-user, multi-location support
- Automatic backups and sync via Render.com database backups
- Image storage: Cloud storage service (AWS S3, Google Cloud Storage, or similar) accessed via Rails backend

### Security & Privacy
- User authentication required (Google or other 3rd party authentication TBD, Keep it simple stupid)
- Location-based data isolation in database
- Secure API integrations (all API keys stored on backend)
- Image storage in secure cloud storage (via Rails backend, not directly from frontend)

---

## User Experience Philosophy

### Conversational & Natural
- Speak naturally, AI understands context
- Interactive dialogue guides the process
- AI maintain's their own converstation style and becomes terse when tasks are pending.

### Visual & Engaging
- Smart Phone and Game-inspired interface design
- Real-time visual feedback
- Rich image displays
- Status indicators and progress tracking
- **Orientation Support**: The app works seamlessly in both landscape and portrait orientations, adapting the interface layout to provide optimal user experience regardless of device orientation

### Efficient & Fast
- Minimal steps from capture to listing
- Background processing doesn't block users
- Quick access to recent items
- Streamlined approval workflows

### Supportive & Helpful
- Error messages are clear and actionable



---

## Target Use Cases

### Primary Use Case: Thrift Store Inventory Processing
Store employees (Agents) walk through inventory, scanning items, having R.E.E.D. identify and research them, then Bootie Bosses finalize Booties into Square to publish them to the online catalog. This is the core operational workflow for store staff.

### Secondary Use Case: Customer/Player Engagement & Gamification
Store customers and guests can participate as **Players** in the gamified experience:

- **Scan & Tag**: Players scan items in the store using their mobile devices
- **Compete on Leaderboards**: Players compete for points and rankings on:
  - Daily leaderboards (reset each day)
  - Weekly leaderboards (reset weekly)
  - Monthly leaderboards (reset monthly)
  - Overall/All-Time leaderboards (cumulative rankings)
- **Earn Points**: Players earn points for various actions:
  - Scanning items
  - Finding T.A.G. items
  - Participating in S.C.O.U.R. runs
  - Completing L.O.C.U.S. audits
  - Sharing Booties on social media
  - Going live and streaming sessions to Facebook, YouTube, or Twitch
- **Track Stats**: Players can view their personal statistics:
  - Total items scanned
  - Total points earned
  - T.A.G. items found
  - Leaderboard rankings
  - Achievements and milestones
- **Social Interaction**: Players can share finds, compete with friends, and engage with the community

**Player Experience**: Customers visiting the store can download the app, scan items they find interesting, participate in daily challenges (like T.A.G.), compete on leaderboards, and have fun while shopping. They can even go live and stream their treasure hunting sessions to Facebook, YouTube, or Twitch, turning their shopping experience into entertainment for viewers. This transforms the shopping experience into an engaging game where customers become active participants in the treasure hunt and can share the excitement with others in real-time.

### Tertiary Use Case: Estate Sale Processing
Processing large collections quickly with AI assistance for identification and recommended bounty calculation.

### Quaternary Use Case: Consignment Shop Management
Managing consignment items with automated research and professional presentation.

---

## Success Metrics (Conceptual)

The application succeeds when:
- Items are processed faster than manual methods
- Pricing accuracy improves through AI research
- User engagement increases (gamification makes work enjoyable)
- Online catalog stays current with new inventory
- Store operators find the process intuitive and efficient

---

## MVP Core Features (Foundation Release)

**Note**: The following features are **core MVP requirements** and must be included in the initial app deployment:

- **Social Sharing & Community** (Feature #12) - **MVP Core**: Share Booties, collections, live streaming to Facebook/YouTube/Twitch/Instagram
- **Basic Gamification** (Feature #11) - **MVP Core**: Leaderboards, points, achievements, basic game modes (S.C.O.U.R., L.O.C.U.S., T.A.G.)
- **Player/Guest Experience** - **MVP Core**: Customers can scan items, compete on leaderboards, participate in challenges
- **Live Streaming Integration** - **MVP Core**: "Go Live" functionality for streaming treasure hunting sessions

**Implementation Priority**: These features should be built as foundational components of the app. If phasing is required for development timeline, they should be implemented no later than necessary, but are considered essential MVP features, not optional enhancements.

**Note on Game Modes**: The basic game modes (S.C.O.U.R., L.O.C.U.S., T.A.G.) are MVP core. Enhanced or additional game modes beyond these are considered future enhancements, not core MVP requirements.

## Future Vision & Expansion

### Planned Enhancements (Post-MVP)
- **Enhanced Game Modes**: Further development of S.C.O.U.R., L.O.C.U.S., and T.A.G. with additional features and competitive elements
- **Advanced Analytics**: Track trends, popular categories, recommended bounty insights
- **Mobile App Optimization**: Native mobile experience optimized for on-the-go use for both Agents and Players
- **Multi-Agent Collaboration**: Teams working together on shared inventory
- **Enhanced Achievement System**: Additional badges, milestones, and rewards beyond MVP
- **Player Rewards**: Integration with store loyalty programs and discounts for top players
- **Community Features**: Enhanced community engagement features, player profiles, and social connections beyond MVP

---

## Summary

**R.E.E.D. Bootie Hunter** is a revolutionary approach to thrift store operations that combines:
- **AI Intelligence** for identification and research
- **Gamification** for engagement and motivation  
- **Real-Time Interaction** for natural, hands-free operation
- **E-Commerce Integration** for seamless catalog management

It transforms routine inventory work into an engaging treasure hunt where store operators partner with an AI assistant to discover, research, and finalize valuable Booties into Square efficiently and enjoyably.

The application is about **making work feel like play** while **dramatically improving efficiency and accuracy** in thrift store operations.

---

---

## Technical Specifications

### Technology Stack

#### Frontend
- **Framework**: Flutter (Dart)
- **Platforms**: Web, iOS, Android (single codebase)
- **State Management**: TBD
- **API Client**: TBD
- **Real-time Communication**: Detmined by Gemini AI model interface and functions. 
#### Backend
- **Framework**: Ruby on Rails (Full Rails, not API-only)
- **Language**: Ruby
- **Architecture**: 
  - Serves JSON API endpoints for Flutter frontend
  - Serves HTML admin interface at `/admin/*` routes

- **Authentication**: 
  - App-level authentication for Flutter users (sign up/login)
  - Simple password authentication for admin interface (via π logo in the bottom right hand of the login screen)
- **Admin Interface**: Custom admin pages within Rails app

#### Database
- **Primary Database**: PostgreSQL
- **ORM**: ActiveRecord (Rails)
- **Migrations**: Database schema managed via Rails migrations

#### External Integrations

**Square MCP (Model Context Protocol)**
- **Purpose**: Catalog add/edit operations for Square e-commerce platform
- **What is MCP**: Model Context Protocol is a standardized protocol for connecting AI applications to external data sources and APIs. MCP servers act as intermediaries that provide structured access to external services.
- **Integration**: Via Rails backend service objects that communicate with Square MCP server
- **Authentication**: Secure token storage in environment variables on Rails backend
- **Operations**: 
  - Adding products to Square catalog
  - Updating product information
  - Managing categories
  - Product finalization (publishing to Square)

**Discogs MCP (Model Context Protocol)**
- **Purpose**: Music database access for records and CDs
- **What is MCP**: Model Context Protocol server that provides structured access to Discogs database
- **Integration**: Via Rails backend service objects that communicate with Discogs MCP server
- **Operations**:
  - Search records/CDs by codes, artist, title
  - Retrieve pricing and sales data
  - Add items to library
  - Get detailed product information for music items
- **Data**: Pricing, sales history, item details for records and CDs
- **Use Case**: Specialized research for music items during Bootie research phase

**AI Models & APIs**

The application uses Google's Gemini AI models for various tasks. These models are integrated via service objects in the Rails backend:

#### **Gemini 2.5 Flash** (`gemini-2.5-flash`)
- **Primary Use Cases**:
  - General chat conversations with R.E.E.D. (text-based)
  - Item research with Google Search grounding
  - Location search with Google Maps grounding
  - General AI tasks requiring reasoning and external data
- **Features**: Fast, efficient, supports grounding with Google Search and Google Maps
- **API**: Google Generative AI SDK (via Rails service objects)
- **Integration**: Called from `ResearchService` for price research and location search

#### **Gemini Flash Lite Latest** (`gemini-flash-lite-latest`)
- **Primary Use Case**: Quick image analysis and item identification
- **Features**: Fast image-to-text processing for initial item recognition
- **Use**: Analyzes uploaded/captured images to generate initial item titles and descriptions
- **Integration**: Called from `ImageProcessingService` or dedicated image analysis service

#### **Gemini 2.5 Flash Image** (`gemini-2.5-flash-image`)
- **Primary Use Case**: AI-powered image editing (also known as "Nano Banana")
- **Features**: 
  - Natural language image editing via text prompts
  - Background removal/replacement
  - Lighting and contrast improvements
  - Style filters and enhancements
  - Precise edits while maintaining object consistency
- **Response Modality**: Returns edited images (IMAGE modality)
- **Use**: All image post-processing and enhancement features
- **Integration**: Called from `ImageProcessingService` for all image editing operations

#### **Gemini 2.5 Flash Native Audio Preview** (`gemini-2.5-flash-native-audio-preview-09-2025`)
- **Primary Use Case**: Live voice and video conversations with R.E.E.D.
- **Features**:
  - Real-time two-way voice communication
  - Continuous video stream processing
  - Vision capabilities (AI can see what the user shows)
  - Tool calling (function declarations)
  - System instructions for R.E.E.D. persona
  - Voice output with Zephyr voice
  - Real-time transcription
- **Response Modality**: Audio output (AUDIO modality)
- **Voice Configuration**: Zephyr (prebuilt voice)
- **Use**: All live phone/video call interactions with R.E.E.D.
- **Integration Architecture**: 
  - **Direct Frontend Connection**: Flutter frontend connects directly to Google's Gemini Live API via WebSocket
  - **Secure Token Exchange**: Frontend requests a session token from Rails backend (which securely stores the Gemini API key)
  - **Tool Call Proxy**: When R.E.E.D. calls tools (like `take_snapshot`, `search_memory`, `get_pending_booties`), these are executed on the Rails backend which has database access
  - **Why Direct Connection**: 
    - Lower latency for audio/video streaming
    - Reduced server load (no proxying of media streams)
    - Better user experience with real-time communication
  - **Why Backend for Tools**: 
    - API keys never exposed to frontend
    - Tool calls need database access (PostgreSQL)
    - Secure execution of sensitive operations

#### **Google Search Grounding**
- **Purpose**: Provides real-world pricing data for item research
- **Integration**: Built into Gemini API calls with `tools: [{ googleSearch: {} }]`
- **Use**: All price research operations to get current market values

#### **Google Maps Grounding**
- **Purpose**: Provides location-based information and place search
- **Integration**: Built into Gemini API calls with `tools: [{ googleMaps: {} }]`
- **Use**: Location search functionality in system configuration

### Backend Architecture

#### Service Objects (Backend Only - Require API Keys or Database Access)

**Must Stay Backend:**
- `SquareCatalogService` - Handles Square MCP integration (requires API keys)
- `DiscogsSearchService` - Handles Discogs MCP integration (requires API keys)
- `ResearchService` - Coordinates AI-powered price research (requires Gemini API keys with Google Search grounding)
- `ImageProcessingService` - Handles image editing and enhancement (requires Gemini API keys)
- `GeminiLiveService` - Handles Gemini Live API session token generation (requires API keys) and tool call execution (requires database access) [we need to research this  I dont think we need to do this because google passes the keys in the backgound or something]
- `AuthenticationService` - User authentication and session management (security-critical)
- `FinalizationService` - Finalizes Booties to Square (requires Square API keys, security-critical)

**Hybrid Approach (Frontend + Backend):**
- **Client-side caching**: Frontend maintains local cache of Booties, locations, user data
- **Optimistic updates**: Frontend can update UI immediately, sync with backend asynchronously
- **Client-side filtering/sorting**: Frontend can filter/sort cached data without backend calls
- **Image preprocessing**: Frontend can compress/resize images before upload
- **Form validation**: Frontend performs first-pass validation, backend does final validation

#### Gemini Live API Tool Execution

- **Tool Call Endpoint**: `/api/v1/gemini/tools` - Receives tool calls from Gemini Live API
- **Tool Functions** (All require backend - need database or API keys): 
  - `take_snapshot` - Captures item image, creates Bootie record (database write)
  - `search_memory` - Searches Booties, chat history, system logs (database query)
  - `get_pending_booties` - Retrieves Booties awaiting attention (database query)
  - `edit_image` - Processes image editing requests (requires Gemini API keys)
  - Additional tools as needed
- **Execution Flow**: 
  1. Frontend connects directly to Gemini Live API
  2. R.E.E.D. calls a tool during conversation
  3. Tool call is sent to Rails backend via API endpoint
  4. Backend executes tool (with database access or API keys)
  5. Backend returns result to frontend
  6. Frontend sends result back to Gemini Live API

#### API Endpoints (JSON)

**Backend Only (Require Database or Security):**
- `/api/v1/auth` - Authentication endpoints (security-critical)
- `/api/v1/items` - Booties/items CRUD operations (database access, validation)
- `/api/v1/locations` - Location management (database access)
- `/api/v1/research` - Research operations (requires Gemini API keys)
- `/api/v1/gemini/tools` - Tool execution (requires database/API keys)
- `/api/v1/finalize` - Finalization to Square (security-critical, requires API keys)

**Frontend Can Handle (with Backend Sync):**
- Client-side state management (cached Booties, locations, user preferences)
- Offline data storage (local cache for offline use)
- UI state (filters, sorting, pagination of cached data)
- Real-time UI updates (optimistic updates, then sync)

#### Frontend-Only Operations

**Client-Side Processing:**
- Image compression and format conversion before upload
- Client-side validation (first pass, backend validates again)
- UI state management (current view, filters, search queries)
- Caching and offline storage (local cache of Booties, locations)
- Real-time UI updates (optimistic updates from cached data)
- Direct Gemini Live API connection (audio/video streaming)
- Client-side filtering/sorting of cached data
- Form data formatting and preparation

**Benefits of Frontend Processing:**
- Reduced server load
- Better offline experience
- Faster UI updates
- Lower latency for user interactions
- Reduced bandwidth (preprocessed images)

#### Admin Routes (HTML)
- `/admin` - Admin dashboard
- `/admin/logs` - System logs viewer
- `/admin/users` - User management
- `/admin/locations` - Location management
- `/admin/items` - Items/Booties management
- Admin login via π logo in bottom right corner

### Database Schema (TBD)

### Development & Deployment

#### Version Control
- **Repository**: GitHub
- **Commit Standards**: Conventional commits (see AGENTS.md)

#### CI/CD Pipeline
- **Platform**: GitHub Actions
- **Workflow**: 
  - Automatic deployment to Render.com on merge to main branch
- **Configuration**: `.github/workflows/` directory (must be confirmed also i dont know shit about workflows so.... make it simple for me.)

#### Deployment
- **Backend**: Render.com (Ruby on Rails service)
- **Database**: TBD
- **Frontend**: Netlify (netlify.toml for details)
- **Environment Variables**: set it up to be Auto confiured from .env in Render.com dashboard
- **Deployment Method**: Automatic via GitHub integration

#### Local Development
- **Rails**: Standard Rails development server
- **Flutter**: Flutter development server for web, and native development for iOS/Android
- **Database**: TBD
- **Environment**: `.env` files for local configuration (not committed automaticly but values can be added to deployment automaticly)

### Security & Authentication

#### User Authentication
- **Method**: App-level authentication (users sign up/login within app)
- **Framework**: Rails authentication (to be determined: Devise, custom, etc.)
- **Sessions**: TBD

#### Admin Authentication
- **Method**: Simple password authentication
- **Access**: Via π (pi) logo in bottom right corner
- **Implementation**: HTTP Basic Auth or custom simple password check

#### API Security
- **HTTPS**: Required in production
- **CSRF Protection**: Rails CSRF tokens
- **Input Validation**: Strong parameters and sanitization
- **Environment Variables**: Sensitive data (API keys, passwords) stored in environment variables

### Development Standards

#### Code Quality
- **Rails**: Follow Rails style guide and conventions
- **Flutter**: Follow Effective Dart style guide
- **Testing**: 
  - Rails: RSpec for unit and integration tests
  - Flutter: Unit tests, widget tests, integration tests
- **Documentation**: See AGENTS.md for detailed guidelines

#### Project Structure
- **Backend**: Standard Rails application structure
- **Frontend**: Standard Flutter project structure
- **Rules Reference**: `rules-reference/` directory for collected best practices
- **Documentation**: AGENTS.md for project guidelines

### Future Technical Considerations

- **Real-time Features**: WebSocket integration for live updates
- **Background Jobs**: Sidekiq or similar for async processing
- **Caching**: Redis for caching frequently accessed data
- **File Storage**: Cloud storage for images (AWS S3, Google Cloud Storage, etc.)
- **Monitoring**: Application monitoring and error tracking
- **Scaling**: Horizontal scaling considerations for high traffic

---

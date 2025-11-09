# R.E.E.D. Refactor V1 - Reedsport Records & Resale

**Project:** Unified R.E.E.D. platform for Reedsport Records & Resale store operations  
**Location:** Reedsport, Oregon  
**Purpose:** Gamified inventory management and e-commerce platform for record and resale store operations

---

## Project Overview

This is the consolidated, production-ready version of the R.E.E.D. (Rapid Estimation & Entry Droid) system, built specifically for Reedsport Records & Resale. It combines the best features from all previous iterations into a single, cohesive platform.

### Core Mission

Transform routine thrift store operations (inventory management, price research, catalog management) into an engaging, gamified treasure hunt experience. Store operators ("Agents") work alongside R.E.E.D. 8, an AI assistant, to discover, research, and finalize valuable items into Square.

---

## Development Plan

### Phase 1: Foundation - Bootie Hunter V1 Validation ✅
**Goal:** Ensure the base system works perfectly as designed

1. **Backend Validation**
   - ✅ Backend is LIVE on Render.com
   - [ ] Verify all API endpoints
   - [ ] Test database migrations
   - [ ] Validate authentication flow
   - [ ] Test Square integration
   - [ ] Test Discogs integration
   - [ ] Verify Gemini Live API integration

2. **Frontend Validation**
   - [ ] Test Flutter frontend locally
   - [ ] Verify all UI components
   - [ ] Test camera/video functionality
   - [ ] Test real-time AI conversation
   - [ ] Validate item capture workflow
   - [ ] Test item research flow
   - [ ] Verify finalization to Square

3. **End-to-End Testing**
   - [ ] Complete workflow: Capture → Research → Finalize
   - [ ] Multi-user testing
   - [ ] Error handling validation
   - [ ] Performance testing
   - [ ] Mobile device testing (iOS/Android)

4. **Deployment**
   - [ ] Deploy Flutter frontend
   - [ ] Configure production environment
   - [ ] Set up monitoring/logging
   - [ ] Create deployment documentation

**Deliverable:** Fully validated, production-ready base system

---

### Phase 2: Image Editing & Voting System 🎨
**Goal:** Add advanced image editing and user engagement features from BHV2

1. **Gemini 2.5 Flash Image Integration**
   - [ ] Research Gemini 2.5 Flash Image API
   - [ ] Create image editing service
   - [ ] Build image editing UI component
   - [ ] Implement natural language editing prompts
   - [ ] Test image editing functionality

2. **Image Voting System**
   - [ ] Design voting database schema
   - [ ] Create voting API endpoints
   - [ ] Build voting UI component
   - [ ] Implement top 3 image selection
   - [ ] Add voting analytics

3. **Image Gallery**
   - [ ] Create image gallery component
   - [ ] Display original + edited images
   - [ ] Show voting results
   - [ ] Implement image comparison view

4. **Integration with Finalization**
   - [ ] Update finalization to use top 3 voted images
   - [ ] Send voted images to Square
   - [ ] Update Square catalog with best images

**Deliverable:** Complete image editing and voting system integrated into base platform

---

### Phase 3: Interface Restreaming 📺
**Goal:** Add ability to restream the entire interface for remote viewing/sharing

1. **Streaming Architecture**
   - [ ] Research streaming solutions (WebRTC, OBS, etc.)
   - [ ] Design streaming architecture
   - [ ] Choose streaming platform/service
   - [ ] Plan bandwidth requirements

2. **Interface Capture**
   - [ ] Implement screen capture functionality
   - [ ] Capture UI + camera feed
   - [ ] Handle audio streaming
   - [ ] Optimize for streaming performance

3. **Streaming Integration**
   - [ ] Build streaming controls UI
   - [ ] Implement start/stop streaming
   - [ ] Add stream quality settings
   - [ ] Create stream sharing links

4. **Remote Viewing**
   - [ ] Build viewer interface
   - [ ] Implement viewer authentication
   - [ ] Add viewer controls (if needed)
   - [ ] Create viewer analytics

**Deliverable:** Complete interface restreaming capability

---

### Phase 4: Additional Game Modes 🎮
**Goal:** Add extra game modes from Treasure Hunter V2/V9

1. **T.A.G. (Targeted Acquisition Game) - Core Mode**
   - [ ] Already implemented in base
   - [ ] Enhance with new features
   - [ ] Add leaderboards
   - [ ] Create daily challenges

2. **L.O.C.U.S. (Logistical Organization & Census Unit Scan)**
   - [ ] Design location audit game
   - [ ] Build location scanning UI
   - [ ] Implement item finding mechanics
   - [ ] Create scoring system
   - [ ] Add location-based leaderboards

3. **S.C.O.U.R. (Stock Count Operational Unit Run)**
   - [ ] Design speed run challenge
   - [ ] Build timer system
   - [ ] Implement speed scoring
   - [ ] Create speed run leaderboards
   - [ ] Add difficulty levels

4. **Gamification Features**
   - [ ] Points system
   - [ ] Achievements/badges
   - [ ] Leaderboards (daily, weekly, monthly, overall)
   - [ ] Social sharing
   - [ ] Team competitions

**Deliverable:** Complete gamification system with all game modes

---

## Technology Stack

### Backend
- **Framework:** Ruby on Rails 8.1.1
- **Database:** PostgreSQL 18.0
- **Background Jobs:** Sidekiq + Redis
- **Deployment:** Render.com
- **Storage:** Google Cloud Storage

### Frontend
- **Framework:** Flutter (Web, iOS, Android)
- **State Management:** Flutter state management
- **AI Integration:** Gemini Live API (hybrid architecture)

### AI & Integrations
- **AI:** Google Gemini AI (multiple models)
- **Image Editing:** Gemini 2.5 Flash Image
- **E-commerce:** Square MCP
- **Music Database:** Discogs MCP

### Streaming (Phase 3)
- **TBD:** WebRTC / OBS / Custom solution

---

## Project Structure

```
ReedRefactorV1/
├── app/                  # Rails application
│   ├── controllers/
│   ├── models/
│   ├── services/
│   └── views/
├── config/               # Rails configuration
├── db/                   # Database migrations and schema
├── lib/                  # Rails libraries
├── scripts/              # Utility scripts
├── frontend/             # Flutter frontend (separate)
│   ├── lib/
│   ├── pubspec.yaml
│   └── ...
├── docs/                 # Documentation
│   ├── phase1-validation.md
│   ├── phase2-image-editing.md
│   ├── phase3-streaming.md
│   ├── phase4-game-modes.md
│   └── ...
├── scripts/              # Utility scripts
├── PLAN.md               # This file (detailed plan)
└── README.md             # Project overview
```

---

## Current Status

- **Phase 1:** 🟡 In Progress (Backend validated, Frontend needs testing)
- **Phase 2:** ⏳ Planned
- **Phase 3:** ⏳ Planned
- **Phase 4:** ⏳ Planned

---

## Getting Started

### Prerequisites
- Ruby 3.0+
- Rails 8.1.1+
- PostgreSQL 12+
- Flutter 3.16+
- Redis (for background jobs)

### Setup
1. Clone this repository
2. Follow setup instructions in root directory (Rails app) and `frontend/` directory
3. See `docs/` for detailed documentation

---

## Contributing

This is a consolidation project. All features should be:
1. Tested thoroughly
2. Documented
3. Integrated seamlessly with existing features
4. Production-ready

---

## License

[To be determined]

---

**Last Updated:** 2025-01-27


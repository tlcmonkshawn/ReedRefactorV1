# R.E.E.D. Bootie Hunter - Documentation

Welcome to the R.E.E.D. Bootie Hunter documentation. This directory contains comprehensive documentation organized by topic.

---

## 📚 Documentation Index

### 🚀 Getting Started

**New to the project?** Start here:

- **[QUICK_START.md](../QUICK_START.md)**: Fast setup guide (5-minute version) ⭐
- **[STATUS_CONDENSED.md](./STATUS_CONDENSED.md)**: Quick status reference ⚡
- **[STATUS.md](./STATUS.md)**: Full project status, progress, and next steps
- **[Installation Guide](./getting-started/installation.md)**: Complete setup instructions
- **[DEVELOPER_HANDOFF.md](../DEVELOPER_HANDOFF.md)**: Developer onboarding guide

### 🏗️ Architecture & Design

- **[ARCHITECTURE.md](./ARCHITECTURE.md)**: System architecture, component design, and integration patterns
- **[API.md](./API.md)**: Complete API endpoint documentation with request/response examples
- **[DATABASE.md](./DATABASE.md)**: Database schema documentation with tables, relationships, and indexes
- **[Database Connection Guide](./database/CONNECTION.md)**: ⚠️ **Connection setup and SSL requirements**
- **[Database Migrations](./database/MIGRATIONS.md)**: Running and managing migrations
- **[Database Troubleshooting](./database/TROUBLESHOOTING.md)**: Common database issues
- **[CONTEXT.md](./CONTEXT.md)**: Context for AI assistants - patterns, conventions, and common tasks

### 🎨 Frontend (Flutter)

- **[LANDING_EXPERIENCE.md](./LANDING_EXPERIENCE.md)**: Landing screen, onboarding flow, and Reed introduction
- **[Frontend Documentation](./frontend/)**: Flutter-specific documentation
  - Login Screen Reference
  - Flutter Path Info
  - Frontend Integration Guide
  - Flutter Deployment Guide

### ⚙️ Backend (Rails)

- **[Backend Documentation](./backend/)**: Rails-specific documentation
  - Gemini Live API Research
  - Prompts Setup Guide

### 🤖 AI & Prompts

- **[PROMPTS.md](./PROMPTS.md)**: AI prompts management system documentation
- **[PROMPTS_CACHE.md](./PROMPTS_CACHE.md)**: Prompts caching architecture and implementation details
- **[PROMPTS_DATABASE.md](./PROMPTS_DATABASE.md)**: Prompts database schema and user functions documentation

### 🚀 Deployment

- **[Deployment Overview](./deployment/overview.md)**: Complete deployment guide for Render.com
- **[Render MCP Integration](./deployment/render-mcp.md)**: Using Render MCP for AI-assisted deployment management
- **[Deployment Troubleshooting](./deployment/troubleshooting.md)**: Common deployment issues and solutions
- **[Viewing Logs](./deployment/viewing-logs.md)**: How to view and analyze Render logs
- **Status**: See [STATUS.md](./STATUS.md) for current deployment status

### 📖 Development

- **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)**: Development workflow, common tasks, and best practices
- **[STATUS.md](./STATUS.md)**: Current implementation progress and known issues

---

## 📁 Documentation Structure

```
docs/
├── README.md                    # This file - documentation index
├── STATUS.md                    # Current project status and progress
├── getting-started/
│   └── installation.md          # Complete installation guide
├── deployment/
│   ├── overview.md              # Deployment guide
│   ├── render-mcp.md            # Render MCP integration guide
│   ├── troubleshooting.md       # Deployment troubleshooting
│   └── viewing-logs.md          # How to view logs
├── frontend/
│   ├── LOGIN_SCREEN_REFERENCE.md
│   ├── FLUTTER_PATH_INFO.md
│   ├── FRONTEND_INTEGRATION.md
│   └── FLUTTER_DEPLOYMENT.md
├── backend/
│   ├── GEMINI_LIVE_API_RESEARCH.md
│   └── PROMPTS_SETUP.md
├── archive/                     # Archived old documentation (ignore)
│   ├── fixes/                   # Old fix documentation
│   ├── old-setup/               # Outdated setup docs
│   └── old-deployment/          # Outdated deployment docs
├── ARCHITECTURE.md              # System architecture
├── API.md                       # API documentation
├── DATABASE.md                  # Database schema
├── database/                    # Database guides
│   ├── README.md                # Database docs index
│   ├── CONNECTION.md            # Connection guide (SSL requirements)
│   ├── MIGRATIONS.md            # Migrations guide
│   └── TROUBLESHOOTING.md       # Troubleshooting guide
├── PROMPTS.md                   # Prompts system
├── PROMPTS_CACHE.md             # Prompts caching
├── PROMPTS_DATABASE.md          # Prompts database
├── LANDING_EXPERIENCE.md        # Landing/onboarding flow
├── CONTEXT.md                   # AI assistant context
└── DEVELOPMENT_GUIDE.md         # Development guide
```

---

## 🎯 Quick Navigation

### For New Developers

1. **Start Here**: [QUICK_START.md](../QUICK_START.md) or [Installation Guide](./getting-started/installation.md)
2. **Check Status**: [STATUS.md](./STATUS.md) - Current project status and next steps
3. **Understand the Product**: [PRODUCT_PROFILE.md](../PRODUCT_PROFILE.md)
4. **Learn the Architecture**: [ARCHITECTURE.md](./ARCHITECTURE.md)
5. **Set Up Development**: [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)
6. **Explore the API**: [API.md](./API.md)
7. **Understand the Database**: [DATABASE.md](./DATABASE.md)

### For AI Assistants

1. **Read Context**: [CONTEXT.md](./CONTEXT.md) for project context and patterns
2. **Review Architecture**: [ARCHITECTURE.md](./ARCHITECTURE.md) for system design
3. **Check Standards**: [AGENTS.md](../AGENTS.md) for coding standards
4. **Reference API**: [API.md](./API.md) and [DATABASE.md](./DATABASE.md) as needed

### For Contributors

1. **Read Standards**: [AGENTS.md](../AGENTS.md) for coding standards and commit guidelines
2. **Review Workflow**: [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) for development workflow
3. **Check Documentation**: [API.md](./API.md) and [DATABASE.md](./DATABASE.md) when making changes
4. **Update Docs**: Keep documentation updated when adding features

---

## 📝 Root Directory Files

Essential files in the project root:

- **[README.md](../README.md)**: Project overview and quick start
- **[QUICK_START.md](../QUICK_START.md)**: Fast setup guide (5 minutes)
- **[DEVELOPER_HANDOFF.md](../DEVELOPER_HANDOFF.md)**: Developer onboarding guide
- **[PRODUCT_PROFILE.md](../PRODUCT_PROFILE.md)**: Product vision and specifications
- **[AGENTS.md](../AGENTS.md)**: Coding standards and guidelines

**Note**: Status and progress information has been consolidated into [STATUS.md](./STATUS.md)

---

## 🔍 Finding Documentation

### By Topic

- **Status & Progress**: [STATUS.md](./STATUS.md) - Current status, progress, and next steps
- **Setup/Installation**: [getting-started/installation.md](./getting-started/installation.md) or [QUICK_START.md](../QUICK_START.md)
- **Deployment**: [deployment/overview.md](./deployment/overview.md)
- **Frontend**: [frontend/](./frontend/) directory
- **Backend**: [backend/](./backend/) directory
- **API**: [API.md](./API.md)
- **Database**: [DATABASE.md](./DATABASE.md) - Schema | [Connection Guide](./database/CONNECTION.md) - Setup
- **Architecture**: [ARCHITECTURE.md](./ARCHITECTURE.md)

### By Role

- **New Developer**: Start with [Installation Guide](./getting-started/installation.md)
- **Frontend Developer**: See [frontend/](./frontend/) and [LANDING_EXPERIENCE.md](./LANDING_EXPERIENCE.md)
- **Backend Developer**: See [backend/](./backend/) and [API.md](./API.md)
- **DevOps**: See [deployment/](./deployment/) directory
- **AI Assistant**: See [CONTEXT.md](./CONTEXT.md)

---

## 🔄 Keeping Documentation Updated

When making changes to the codebase:

1. **API Changes**: Update [API.md](./API.md) with new endpoints or changes
2. **Database Changes**: Update [DATABASE.md](./DATABASE.md) with schema changes
3. **Architecture Changes**: Update [ARCHITECTURE.md](./ARCHITECTURE.md) if system design changes
4. **Prompt Changes**: Update [PROMPTS.md](./PROMPTS.md) if prompts system changes
5. **UI/UX Changes**: Update [LANDING_EXPERIENCE.md](./LANDING_EXPERIENCE.md) if onboarding or landing flow changes
6. **Code Comments**: Update inline code comments when modifying logic
7. **New Features**: Reference [PRODUCT_PROFILE.md](../PRODUCT_PROFILE.md) for feature specifications

---

## ❓ Questions?

- **Product Questions**: See [PRODUCT_PROFILE.md](../PRODUCT_PROFILE.md)
- **Technical Questions**: See [ARCHITECTURE.md](./ARCHITECTURE.md) or [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)
- **API Questions**: See [API.md](./API.md)
- **Database Questions**: See [DATABASE.md](./DATABASE.md) for schema | [Connection Guide](./database/CONNECTION.md) for connection issues
- **Prompts Questions**: See [PROMPTS.md](./PROMPTS.md)
- **UI/UX Questions**: See [LANDING_EXPERIENCE.md](./LANDING_EXPERIENCE.md)
- **Development Questions**: See [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)
- **Deployment Questions**: See [deployment/overview.md](./deployment/overview.md)

---

*Last Updated: 2025-01-27 - Documentation consolidated by DOC*

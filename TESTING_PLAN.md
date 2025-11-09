# Testing Plan for GCP Migration

This document outlines the testing strategy for the GCP migration.

## Test Environment

- **Backend**: Cloud Run service `reed-refactor-v1-backend`
- **Frontend**: Cloud Run service `reed-refactor-v1-frontend`
- **Database**: Firestore (Native mode)
- **Storage**: Google Cloud Storage bucket `reed-refactor-v1-images`

## Test Categories

### 1. Infrastructure Tests

#### Firestore Connection
- [ ] Verify Firestore client initializes correctly
- [ ] Test collection creation (automatic on first write)
- [ ] Verify document reads/writes work
- [ ] Test query operations
- [ ] Verify indexes are created (if needed)

#### Cloud Storage
- [ ] Verify GCS bucket is accessible
- [ ] Test image upload
- [ ] Test image retrieval
- [ ] Verify permissions are correct

#### Secret Manager
- [ ] Verify all secrets are accessible from Cloud Run
- [ ] Test secret rotation (if needed)
- [ ] Verify secrets are not exposed in logs

### 2. Backend API Tests

#### Health Check
```bash
curl https://reed-refactor-v1-backend-XXX-uw.a.run.app/health
```
- [ ] Returns 200 status
- [ ] Includes Firestore connection status
- [ ] Includes collection status

#### Authentication
- [ ] User registration: `POST /api/v1/auth/register`
- [ ] User login: `POST /api/v1/auth/login`
- [ ] Get current user: `GET /api/v1/auth/me`
- [ ] JWT token validation
- [ ] Token expiration handling

#### Booties API
- [ ] List booties: `GET /api/v1/booties`
- [ ] Create bootie: `POST /api/v1/booties`
- [ ] Get bootie: `GET /api/v1/booties/:id`
- [ ] Update bootie: `PUT /api/v1/booties/:id`
- [ ] Delete bootie: `DELETE /api/v1/booties/:id`
- [ ] Filter by status, category, location
- [ ] Authorization (users can only see their own)

#### Research Workflow
- [ ] Submit bootie for research
- [ ] Research service execution
- [ ] Research results storage
- [ ] Grounding sources creation

#### Finalization Workflow
- [ ] Finalize bootie (Bootie Boss only)
- [ ] Square catalog integration
- [ ] Status updates

### 3. Frontend Tests

#### Basic Functionality
- [ ] Application loads
- [ ] Login screen displays
- [ ] Registration works
- [ ] Navigation works
- [ ] API calls succeed

#### Bootie Management
- [ ] List booties
- [ ] Create new bootie
- [ ] Upload images
- [ ] View bootie details
- [ ] Edit bootie

#### Image Handling
- [ ] Image upload to GCS
- [ ] Image display from GCS
- [ ] Image processing (if applicable)

#### Gemini Live Integration
- [ ] Session token generation
- [ ] WebSocket connection
- [ ] Tool calls execution
- [ ] Audio/video streaming

### 4. Integration Tests

#### End-to-End Workflows
- [ ] Complete bootie creation workflow:
  1. User registers/logs in
  2. Creates bootie with image
  3. Submits for research
  4. Research completes
  5. Bootie Boss finalizes
  6. Bootie appears in Square catalog

#### Data Consistency
- [ ] User data persists across requests
- [ ] Bootie associations (user, location) work
- [ ] Research logs are linked correctly
- [ ] Scores and achievements update correctly

### 5. Performance Tests

#### Response Times
- [ ] Health check < 100ms
- [ ] API endpoints < 500ms (average)
- [ ] Image upload < 5s (depending on size)
- [ ] Firestore queries < 200ms

#### Load Testing
- [ ] Handle 10 concurrent users
- [ ] Handle 100 concurrent users
- [ ] Auto-scaling works correctly
- [ ] No memory leaks

### 6. Security Tests

#### Authentication
- [ ] Invalid credentials rejected
- [ ] Expired tokens rejected
- [ ] Unauthorized access blocked

#### Authorization
- [ ] Users can only access their own data
- [ ] Admin-only endpoints protected
- [ ] Bootie Boss permissions work

#### Data Validation
- [ ] Input validation works
- [ ] SQL injection prevention (N/A - using Firestore)
- [ ] XSS prevention
- [ ] CORS configured correctly

### 7. Error Handling Tests

#### Network Errors
- [ ] Firestore connection failures handled
- [ ] GCS connection failures handled
- [ ] API timeouts handled gracefully

#### Validation Errors
- [ ] Invalid input returns 400
- [ ] Missing required fields handled
- [ ] Error messages are clear

#### Server Errors
- [ ] 500 errors logged correctly
- [ ] Error responses don't expose sensitive data
- [ ] Application recovers from errors

## Test Execution

### Manual Testing
1. Use Postman/curl for API testing
2. Use browser for frontend testing
3. Check Cloud Run logs for errors
4. Monitor Firestore usage in console

### Automated Testing (Future)
- Set up RSpec tests for backend
- Set up Flutter tests for frontend
- Set up integration tests
- Set up CI/CD test pipeline

## Test Data

### Test Users
- Admin user: `admin@reedsportrecords.com`
- Regular user: `test@example.com`
- Bootie Boss: `boss@reedsportrecords.com`

### Test Booties
- Create test booties in various categories
- Test with and without images
- Test different statuses

## Success Criteria

All tests must pass before considering migration complete:
- [ ] All infrastructure tests pass
- [ ] All API endpoints respond correctly
- [ ] Frontend can communicate with backend
- [ ] No critical errors in logs
- [ ] Performance meets requirements
- [ ] Security tests pass

## Known Issues

Document any issues found during testing:
- Issue 1: [Description]
- Issue 2: [Description]

## Test Results

Date: __________
Tester: __________
Results: [Pass/Fail for each category]


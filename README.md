# Local-Model-Stability-Profiler
- **Working Name:** LlamaStables
- **Technical Description:** A self-hosted web dashboard that automatically tests AI models against your hardware. Discovers Ollama models, runs stability tests, monitors system resources in real-time, and provides ranked recommendations based on performance and reliability metrics.
- **Purpose:** Help users identify optimal models for their specific hardware configuration through automated testing and analysis.
- **Tech Stack:** Python, Flask, Ollama API, Real-time monitoring 

## MVP Success Criteria
- [ ] Web dashboard accessible at localhost:5000
- [ ] Auto-discovers installed Ollama models
- [ ] Displays real-time system metrics
- [ ] Runs basic stability tests on selected models
- [ ] Provides stability scores and rankings
- [ ] Handles crashes gracefully without system freeze

## MVP IMPLEMENTATION ROADMAP
### Week 1: Basic Flask App Foundation
- [ ] Set up project structure and dependencies
- [ ] Create basic Flask application skeleton
- [ ] Implement model discovery (ollama list integration)
- [ ] Build basic HTML dashboard template
- [ ] Add real-time system metrics display (CPU, RAM, GPU)
- [ ] Test basic web interface functionality

### **Week 1 Complete When:**
- Flask server runs without errors
- Dashboard displays list of Ollama models
- System metrics update in real-time
- Basic navigation works

### Week 2: Testing Engine Core
- [ ] Implement model selection interface with checkboxes
- [ ] Create simple test runner with basic prompts
- [ ] Add crash detection and error handling
- [ ] Build progress tracking and real-time updates
- [ ] Implement basic results storage and display
- [ ] Add start/stop testing controls

### **Week 2 Complete When:**
- Users can select models and start tests
- Tests run with progress indication
- Basic pass/fail results displayed
- No system crashes during testing

### Week 3: Polish & Results System
- [ ] Develop stability scoring algorithm (1-10 scale)
- [ ] Implement model ranking and sorting
- [ ] Create basic recommendation engine
- [ ] Add comprehensive error handling
- [ ] Polish UI/UX and styling
- [ ] Final testing and bug fixes

### **Week 3 Complete When:**
- Models ranked by stability score
- Clear recommendations provided
- UI is polished and user-friendly
- Tool is usable for its intended purpose

## **Stretch Goals (Post-MVP)**
- Advanced stress testing (hour-long tests)
- Custom test prompt creation
- Historical results comparison
- Export functionality
- Multi-user support
- Advanced analytics dashboard

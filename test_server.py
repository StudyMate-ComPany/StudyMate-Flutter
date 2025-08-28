#!/usr/bin/env python3
"""
StudyMate Test Server
간단한 테스트 API 서버
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import datetime
import random

class StudyMateTestHandler(BaseHTTPRequestHandler):
    def _set_headers(self, status=200):
        self.send_response(status)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def do_OPTIONS(self):
        self._set_headers(200)
    
    def do_GET(self):
        if self.path == '/':
            self._set_headers()
            response = {
                'status': 'success',
                'message': 'StudyMate API Server is running!',
                'version': '1.0.0',
                'timestamp': datetime.datetime.now().isoformat()
            }
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/api/health':
            self._set_headers()
            response = {
                'status': 'healthy',
                'database': 'connected',
                'cache': 'connected',
                'timestamp': datetime.datetime.now().isoformat()
            }
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/api/user':
            self._set_headers()
            response = {
                'id': 1,
                'username': 'testuser',
                'email': 'test@studymate.com',
                'name': '테스트 사용자',
                'created_at': '2024-01-01T00:00:00Z'
            }
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/api/goals':
            self._set_headers()
            response = {
                'goals': [
                    {
                        'id': 1,
                        'title': 'Python 마스터하기',
                        'description': 'Python 고급 기능 학습',
                        'progress': 65,
                        'deadline': '2024-12-31'
                    },
                    {
                        'id': 2,
                        'title': 'Flutter 앱 개발',
                        'description': '크로스플랫폼 앱 개발 학습',
                        'progress': 40,
                        'deadline': '2024-11-30'
                    }
                ]
            }
            self.wfile.write(json.dumps(response).encode())
        
        else:
            self._set_headers(404)
            response = {'error': 'Not Found'}
            self.wfile.write(json.dumps(response).encode())
    
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        try:
            data = json.loads(post_data.decode())
        except:
            data = {}
        
        if self.path == '/api/auth/login':
            self._set_headers()
            response = {
                'status': 'success',
                'token': 'test_token_' + str(random.randint(1000, 9999)),
                'user': {
                    'id': 1,
                    'username': data.get('username', 'testuser'),
                    'email': data.get('email', 'test@studymate.com')
                }
            }
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/api/auth/register':
            self._set_headers()
            response = {
                'status': 'success',
                'message': 'User registered successfully',
                'user': {
                    'id': random.randint(100, 999),
                    'username': data.get('username', 'newuser'),
                    'email': data.get('email', 'new@studymate.com')
                }
            }
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/api/goals':
            self._set_headers()
            response = {
                'status': 'success',
                'goal': {
                    'id': random.randint(10, 99),
                    'title': data.get('title', 'New Goal'),
                    'description': data.get('description', ''),
                    'progress': 0,
                    'created_at': datetime.datetime.now().isoformat()
                }
            }
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/api/ai/chat':
            self._set_headers()
            response = {
                'status': 'success',
                'response': f"AI 응답: {data.get('message', 'Hello')}에 대한 답변입니다.",
                'suggestions': ['추가 학습 자료', '연습 문제', '관련 주제']
            }
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/test':
            self._set_headers()
            response = {
                'status': 'success',
                'echo': data,
                'timestamp': datetime.datetime.now().isoformat()
            }
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/api/study/sessions/start/':
            self._set_headers()
            response = {
                'id': str(random.randint(1000, 9999)),
                'goal_id': data.get('goal_id'),
                'subject': data.get('subject', 'Default Subject'),
                'topic': data.get('topic', ''),
                'type': data.get('type', 'focused'),
                'planned_duration': data.get('planned_duration', 25),
                'start_time': datetime.datetime.now().isoformat(),
                'is_active': True,
                'is_paused': False,
                'paused_duration': 0
            }
            self.wfile.write(json.dumps(response).encode())
        
        elif '/api/study/sessions/' in self.path and self.path.endswith('/end/'):
            self._set_headers()
            session_id = self.path.split('/')[-3]
            response = {
                'id': session_id,
                'end_time': datetime.datetime.now().isoformat(),
                'actual_duration': random.randint(10, 60),
                'is_active': False,
                'status': 'completed',
                'notes': data.get('notes', ''),
                'effectiveness': data.get('effectiveness', 3)
            }
            self.wfile.write(json.dumps(response).encode())
        
        else:
            self._set_headers(404)
            response = {'error': 'Not Found'}
            self.wfile.write(json.dumps(response).encode())

def run_server(port=8000):
    server_address = ('', port)
    httpd = HTTPServer(server_address, StudyMateTestHandler)
    print(f'🚀 StudyMate Test Server running on http://localhost:{port}')
    print(f'📱 Network access: http://YOUR_IP:{port}')
    print('Press Ctrl+C to stop the server\n')
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print('\n✋ Server stopped')
        httpd.server_close()

if __name__ == '__main__':
    import sys
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    run_server(port)
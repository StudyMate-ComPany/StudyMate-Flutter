#!/usr/bin/env python3
"""
Enhanced StudyMate Test Server
완전한 기능을 갖춘 테스트 API 서버
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import datetime
import random
import uuid

# 메모리 저장소
users = {}
sessions = []
goals = []
ai_history = []

# 기본 테스트 유저 생성
test_user = {
    'id': '1',
    'email': 'test@studymate.com',
    'username': 'testuser',
    'name': '테스트 유저',
    'created_at': datetime.datetime.now().isoformat(),
    'token': 'test_token_12345'
}
users['test@studymate.com'] = test_user

# 샘플 학습 목표
sample_goals = [
    {
        'id': '1',
        'title': 'Flutter 마스터하기',
        'description': 'Flutter로 완벽한 앱 개발하기',
        'goal_type': 'custom',
        'status': 'active',
        'start_date': '2025-01-01',
        'end_date': '2025-12-31',
        'target_date': '2025-12-31',
        'target_summaries': 10,
        'target_quizzes': 5,
        'target_study_time': '10:00:00',
        'current_summaries': 3,
        'current_quizzes': 2,
        'current_study_time': '03:30:00',
        'progress': {'completed': 35, 'total': 100},
        'progress_percentage': 35.0,
        'created_at': datetime.datetime.now().isoformat(),
        'updated_at': datetime.datetime.now().isoformat()
    },
    {
        'id': '2',
        'title': 'Python 고급 과정',
        'description': '파이썬 고급 기능 학습',
        'goal_type': 'custom',
        'status': 'active',
        'start_date': '2025-01-01',
        'end_date': '2025-11-30',
        'target_date': '2025-11-30',
        'target_summaries': 8,
        'target_quizzes': 4,
        'target_study_time': '08:00:00',
        'current_summaries': 5,
        'current_quizzes': 2,
        'current_study_time': '04:48:00',
        'progress': {'completed': 60, 'total': 100},
        'progress_percentage': 60.0,
        'created_at': datetime.datetime.now().isoformat(),
        'updated_at': datetime.datetime.now().isoformat()
    },
    {
        'id': '3',
        'title': 'AI/ML 기초',
        'description': '인공지능과 머신러닝 기초 이해',
        'goal_type': 'custom',
        'status': 'active',
        'start_date': '2025-01-01',
        'end_date': '2025-10-31',
        'target_date': '2025-10-31',
        'target_summaries': 15,
        'target_quizzes': 10,
        'target_study_time': '20:00:00',
        'current_summaries': 3,
        'current_quizzes': 2,
        'current_study_time': '04:00:00',
        'progress': {'completed': 20, 'total': 100},
        'progress_percentage': 20.0,
        'created_at': datetime.datetime.now().isoformat(),
        'updated_at': datetime.datetime.now().isoformat()
    }
]
goals = sample_goals.copy()

class EnhancedTestHandler(BaseHTTPRequestHandler):
    def _set_headers(self, status=200):
        self.send_response(status)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()
    
    def do_OPTIONS(self):
        self._set_headers(200)
    
    def do_GET(self):
        # 메인 페이지
        if self.path == '/':
            self._set_headers()
            response = {
                'status': 'success',
                'message': 'Enhanced StudyMate API Server is running!',
                'version': '2.0.0',
                'timestamp': datetime.datetime.now().isoformat(),
                'endpoints': {
                    'auth': ['/api/auth/login', '/api/auth/register', '/api/auth/logout'],
                    'user': ['/api/users/me', '/api/user'],
                    'goals': ['/api/study/goals', '/api/goals'],
                    'sessions': ['/api/study/sessions', '/api/study/sessions/start'],
                    'ai': ['/api/study/ai/chat', '/api/study/ai/history']
                }
            }
            self.wfile.write(json.dumps(response).encode())
        
        # 사용자 정보
        elif self.path in ['/api/users/me/', '/api/users/me', '/api/user/', '/api/user']:
            auth_header = self.headers.get('Authorization')
            if auth_header and 'Token' in auth_header:
                self._set_headers()
                response = {
                    'id': test_user['id'],
                    'email': test_user['email'],
                    'username': test_user['username'],
                    'name': test_user['name'],
                    'profile_name': test_user['name'],
                    'created_at': test_user['created_at'],
                    'date_joined': test_user['created_at']
                }
                self.wfile.write(json.dumps(response).encode())
            else:
                self._set_headers(401)
                response = {
                    'error': True,
                    'message': '인증이 필요합니다',
                    'code': 'not_authenticated'
                }
                self.wfile.write(json.dumps(response).encode())
        
        # 학습 목표 목록
        elif self.path in ['/api/study/goals/', '/api/study/goals', '/api/goals/', '/api/goals']:
            self._set_headers()
            response = {
                'results': goals,
                'count': len(goals),
                'next': None,
                'previous': None
            }
            self.wfile.write(json.dumps(response).encode())
        
        # 학습 세션 목록
        elif self.path in ['/api/study/sessions/', '/api/study/sessions']:
            self._set_headers()
            response = {
                'results': sessions,
                'count': len(sessions),
                'next': None,
                'previous': None
            }
            self.wfile.write(json.dumps(response).encode())
        
        # AI 대화 기록
        elif self.path in ['/api/study/ai/history/', '/api/study/ai/history']:
            self._set_headers()
            response = {
                'history': ai_history,
                'count': len(ai_history)
            }
            self.wfile.write(json.dumps(response).encode())
        
        # 통계
        elif self.path in ['/api/study/stats/overview/', '/api/study/stats/overview']:
            self._set_headers()
            response = {
                'total_study_time': random.randint(100, 500),
                'total_sessions': len(sessions),
                'active_goals': len([g for g in goals if g.get('status') == 'in_progress']),
                'completed_goals': len([g for g in goals if g.get('status') == 'completed']),
                'weekly_data': [
                    {'day': 'Mon', 'hours': random.randint(1, 5)},
                    {'day': 'Tue', 'hours': random.randint(1, 5)},
                    {'day': 'Wed', 'hours': random.randint(1, 5)},
                    {'day': 'Thu', 'hours': random.randint(1, 5)},
                    {'day': 'Fri', 'hours': random.randint(1, 5)},
                    {'day': 'Sat', 'hours': random.randint(1, 5)},
                    {'day': 'Sun', 'hours': random.randint(1, 5)}
                ]
            }
            self.wfile.write(json.dumps(response).encode())
        
        else:
            self._set_headers(404)
            response = {'error': 'Not Found', 'path': self.path}
            self.wfile.write(json.dumps(response).encode())
    
    def do_POST(self):
        content_length = int(self.headers['Content-Length'] if self.headers['Content-Length'] else 0)
        post_data = self.rfile.read(content_length) if content_length > 0 else b'{}'
        
        try:
            data = json.loads(post_data.decode())
        except:
            data = {}
        
        # 로그인
        if self.path in ['/api/auth/login/', '/api/auth/login']:
            email = data.get('email', 'test@studymate.com')
            if email not in users:
                # 자동으로 사용자 생성
                new_user = {
                    'id': str(len(users) + 1),
                    'email': email,
                    'username': email.split('@')[0],
                    'name': email.split('@')[0].title(),
                    'created_at': datetime.datetime.now().isoformat(),
                    'token': f'test_token_{random.randint(10000, 99999)}'
                }
                users[email] = new_user
            
            self._set_headers()
            user = users[email]
            response = {
                'token': user['token'],
                'user': {
                    'id': user['id'],
                    'email': user['email'],
                    'username': user['username'],
                    'name': user['name']
                }
            }
            self.wfile.write(json.dumps(response).encode())
        
        # 회원가입
        elif self.path in ['/api/auth/register/', '/api/auth/register']:
            email = data.get('email', f'user{random.randint(100,999)}@studymate.com')
            new_user = {
                'id': str(len(users) + 1),
                'email': email,
                'username': data.get('username', email.split('@')[0]),
                'name': data.get('name', data.get('profile_name', 'New User')),
                'created_at': datetime.datetime.now().isoformat(),
                'token': f'test_token_{random.randint(10000, 99999)}'
            }
            users[email] = new_user
            
            self._set_headers()
            response = {
                'token': new_user['token'],
                'user': {
                    'id': new_user['id'],
                    'email': new_user['email'],
                    'username': new_user['username'],
                    'name': new_user['name']
                }
            }
            self.wfile.write(json.dumps(response).encode())
        
        # 로그아웃
        elif self.path in ['/api/auth/logout/', '/api/auth/logout']:
            self._set_headers()
            response = {'status': 'success', 'message': 'Logged out successfully'}
            self.wfile.write(json.dumps(response).encode())
        
        # 학습 목표 생성
        elif self.path in ['/api/study/goals/', '/api/study/goals', '/api/goals/', '/api/goals']:
            new_goal = {
                'id': str(len(goals) + 1),
                'title': data.get('title', 'New Goal'),
                'description': data.get('description', ''),
                'target_date': data.get('target_date', '2025-12-31'),
                'progress': 0,
                'status': 'in_progress',
                'created_at': datetime.datetime.now().isoformat()
            }
            goals.append(new_goal)
            
            self._set_headers()
            self.wfile.write(json.dumps(new_goal).encode())
        
        # 학습 세션 시작
        elif self.path in ['/api/study/sessions/start/', '/api/study/sessions/start']:
            new_session = {
                'id': str(len(sessions) + 1),
                'goal_id': data.get('goal_id'),
                'subject': data.get('subject', 'General Study'),
                'topic': data.get('topic', ''),
                'type': data.get('type', 'focused'),
                'planned_duration': data.get('planned_duration', 25),
                'start_time': datetime.datetime.now().isoformat(),
                'is_active': True,
                'is_paused': False,
                'paused_duration': 0,
                'actual_duration': 0
            }
            sessions.append(new_session)
            
            self._set_headers()
            self.wfile.write(json.dumps(new_session).encode())
        
        # 학습 세션 종료
        elif '/api/study/sessions/' in self.path and self.path.endswith('/end/'):
            session_id = self.path.split('/')[-3]
            
            # 세션 찾아서 업데이트
            for session in sessions:
                if session['id'] == session_id:
                    session['end_time'] = datetime.datetime.now().isoformat()
                    session['is_active'] = False
                    session['actual_duration'] = data.get('duration', random.randint(10, 60))
                    session['notes'] = data.get('notes', '')
                    session['effectiveness'] = data.get('effectiveness', 3)
                    break
            
            self._set_headers()
            response = {
                'id': session_id,
                'status': 'completed',
                'message': 'Session ended successfully'
            }
            self.wfile.write(json.dumps(response).encode())
        
        # AI 채팅
        elif self.path in ['/api/study/ai/chat/', '/api/study/ai/chat']:
            ai_response = {
                'id': str(uuid.uuid4()),
                'user_id': '1',
                'type': 'explanation',
                'query': data.get('message', ''),
                'response': f"테스트 AI 응답: {data.get('message', 'Hello')}에 대한 답변입니다.\n\n다음과 같은 내용을 학습하시면 좋습니다:\n1. 기초 개념 이해\n2. 실습 예제 풀기\n3. 프로젝트 적용하기",
                'created_at': datetime.datetime.now().isoformat(),
                'confidence': 0.85
            }
            ai_history.append(ai_response)
            
            self._set_headers()
            self.wfile.write(json.dumps(ai_response).encode())
        
        else:
            self._set_headers(404)
            response = {'error': 'Not Found', 'path': self.path}
            self.wfile.write(json.dumps(response).encode())
    
    def do_PUT(self):
        content_length = int(self.headers['Content-Length'] if self.headers['Content-Length'] else 0)
        put_data = self.rfile.read(content_length) if content_length > 0 else b'{}'
        
        try:
            data = json.loads(put_data.decode())
        except:
            data = {}
        
        # 학습 목표 수정
        if '/api/study/goals/' in self.path or '/api/goals/' in self.path:
            goal_id = self.path.split('/')[-2] if self.path.endswith('/') else self.path.split('/')[-1]
            
            for goal in goals:
                if goal['id'] == goal_id:
                    goal.update(data)
                    self._set_headers()
                    self.wfile.write(json.dumps(goal).encode())
                    return
            
            self._set_headers(404)
            response = {'error': 'Goal not found'}
            self.wfile.write(json.dumps(response).encode())
        
        else:
            self._set_headers(404)
            response = {'error': 'Not Found', 'path': self.path}
            self.wfile.write(json.dumps(response).encode())
    
    def do_DELETE(self):
        # 학습 목표 삭제
        if '/api/study/goals/' in self.path or '/api/goals/' in self.path:
            goal_id = self.path.split('/')[-2] if self.path.endswith('/') else self.path.split('/')[-1]
            
            global goals
            goals = [g for g in goals if g['id'] != goal_id]
            
            self._set_headers(204)
        
        else:
            self._set_headers(404)
            response = {'error': 'Not Found', 'path': self.path}
            self.wfile.write(json.dumps(response).encode())

def run_server(port=8000):
    server_address = ('', port)
    httpd = HTTPServer(server_address, EnhancedTestHandler)
    print(f'🚀 Enhanced StudyMate Test Server running on http://localhost:{port}')
    print(f'📱 Network access: http://YOUR_IP:{port}')
    print(f'\n📋 Available Endpoints:')
    print(f'  - POST /api/auth/login')
    print(f'  - POST /api/auth/register')
    print(f'  - GET  /api/users/me')
    print(f'  - GET  /api/study/goals')
    print(f'  - POST /api/study/goals')
    print(f'  - GET  /api/study/sessions')
    print(f'  - POST /api/study/sessions/start')
    print(f'  - POST /api/study/ai/chat')
    print(f'\n✅ Server is ready!')
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print('\n🛑 Server stopped.')
        httpd.shutdown()

if __name__ == '__main__':
    run_server()
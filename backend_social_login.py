#!/usr/bin/env python3
"""
StudyMate Backend - Social Login Handler
카카오 소셜 로그인 처리를 위한 간단한 백엔드 서버
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import jwt
import datetime
import hashlib
import uuid

app = Flask(__name__)
CORS(app)

# 간단한 인메모리 사용자 저장소
users_db = {}
tokens_db = {}

# 비밀 키 (실제 환경에서는 환경 변수로 관리해야 함)
SECRET_KEY = "studymate_secret_key_2024"
KAKAO_REST_API_KEY = "28959594f89d8dd0262b7e0062c0fbe8"

def generate_token(user_id):
    """JWT 토큰 생성"""
    payload = {
        'user_id': user_id,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(days=30),
        'iat': datetime.datetime.utcnow()
    }
    return jwt.encode(payload, SECRET_KEY, algorithm='HS256')

def verify_kakao_token(access_token):
    """카카오 액세스 토큰 검증 및 사용자 정보 가져오기"""
    try:
        # 카카오 사용자 정보 API 호출
        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8'
        }
        
        response = requests.get(
            'https://kapi.kakao.com/v2/user/me',
            headers=headers
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Kakao API Error: {response.status_code}, {response.text}")
            return None
            
    except Exception as e:
        print(f"Error verifying Kakao token: {e}")
        return None

@app.route('/api/auth/social/login/', methods=['POST'])
def social_login():
    """소셜 로그인 처리"""
    try:
        data = request.json
        print(f"Received social login request: {data}")
        
        provider = data.get('provider')
        
        if provider == 'kakao':
            # 카카오 로그인 처리
            access_token = data.get('access_token')
            
            if not access_token:
                # access_token이 없으면 기본 정보로 처리
                user_id = data.get('id')
                email = data.get('email', '')
                name = data.get('name', '')
            else:
                # 카카오 토큰 검증
                kakao_user = verify_kakao_token(access_token)
                if not kakao_user:
                    # 토큰 검증 실패 시 기본 정보 사용
                    user_id = data.get('id')
                    email = data.get('email', '')
                    name = data.get('name', '')
                else:
                    # 카카오에서 가져온 정보 사용
                    user_id = str(kakao_user.get('id'))
                    kakao_account = kakao_user.get('kakao_account', {})
                    email = kakao_account.get('email', '')
                    profile = kakao_account.get('profile', {})
                    name = profile.get('nickname', '')
            
            # 사용자 정보 저장 또는 업데이트
            user_key = f"kakao_{user_id}"
            
            if user_key not in users_db:
                # 새 사용자 생성
                users_db[user_key] = {
                    'id': user_key,
                    'provider_id': user_id,
                    'email': email,
                    'username': email.split('@')[0] if email else f"kakao_{user_id}",
                    'name': name,
                    'first_name': name.split(' ')[0] if name else '',
                    'last_name': ' '.join(name.split(' ')[1:]) if name and len(name.split(' ')) > 1 else '',
                    'profile_image': data.get('profileImage', ''),
                    'provider': 'kakao',
                    'created_at': datetime.datetime.utcnow().isoformat()
                }
                created = True
                print(f"Created new user: {user_key}")
            else:
                # 기존 사용자 업데이트
                users_db[user_key].update({
                    'last_login': datetime.datetime.utcnow().isoformat(),
                    'profile_image': data.get('profileImage', ''),
                })
                created = False
                print(f"Updated existing user: {user_key}")
            
            # JWT 토큰 생성
            token = generate_token(user_key)
            tokens_db[token] = user_key
            
            # 응답 생성
            response_data = {
                'token': token,
                'user': {
                    'id': users_db[user_key]['id'],
                    'email': users_db[user_key]['email'],
                    'username': users_db[user_key]['username'],
                    'name': users_db[user_key]['name'],
                    'first_name': users_db[user_key]['first_name'],
                    'last_name': users_db[user_key]['last_name'],
                    'profile': {
                        'profile_image': users_db[user_key]['profile_image'],
                        'name': users_db[user_key]['name'],
                    }
                },
                'created': created,
                'message': '카카오 로그인 성공' if created else '카카오 로그인 (재로그인) 성공'
            }
            
            print(f"Returning successful response: {response_data}")
            return jsonify(response_data), 200
            
        else:
            # 다른 소셜 로그인 제공자 (구글, 네이버, 애플 등)
            return jsonify({
                'error': f'{provider} 로그인은 아직 지원되지 않습니다'
            }), 501
            
    except Exception as e:
        print(f"Error in social login: {e}")
        return jsonify({
            'error': '소셜 로그인 처리 중 오류가 발생했습니다',
            'details': str(e)
        }), 500

@app.route('/api/auth/logout/', methods=['POST'])
def logout():
    """로그아웃 처리"""
    auth_header = request.headers.get('Authorization')
    if auth_header and auth_header.startswith('Token '):
        token = auth_header[6:]
        if token in tokens_db:
            del tokens_db[token]
    
    return jsonify({'message': '로그아웃 성공'}), 200

@app.route('/api/user/profile/', methods=['GET'])
def get_profile():
    """사용자 프로필 조회"""
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith('Token '):
        return jsonify({'error': '인증이 필요합니다'}), 401
    
    token = auth_header[6:]
    if token not in tokens_db:
        return jsonify({'error': '유효하지 않은 토큰입니다'}), 401
    
    user_key = tokens_db[token]
    if user_key not in users_db:
        return jsonify({'error': '사용자를 찾을 수 없습니다'}), 404
    
    user = users_db[user_key]
    return jsonify({
        'id': user['id'],
        'email': user['email'],
        'username': user['username'],
        'name': user['name'],
        'profile_image': user['profile_image'],
        'provider': user['provider']
    }), 200

@app.route('/health', methods=['GET'])
def health_check():
    """헬스 체크"""
    return jsonify({
        'status': 'healthy',
        'service': 'StudyMate Social Login Backend',
        'timestamp': datetime.datetime.utcnow().isoformat()
    }), 200

if __name__ == '__main__':
    print("=" * 60)
    print("StudyMate Social Login Backend Server")
    print("=" * 60)
    print("서버가 http://localhost:5000 에서 실행중입니다")
    print("")
    print("엔드포인트:")
    print("  - POST /api/auth/social/login/ : 소셜 로그인")
    print("  - POST /api/auth/logout/ : 로그아웃")
    print("  - GET  /api/user/profile/ : 프로필 조회")
    print("  - GET  /health : 헬스 체크")
    print("=" * 60)
    
    app.run(host='0.0.0.0', port=5000, debug=True)
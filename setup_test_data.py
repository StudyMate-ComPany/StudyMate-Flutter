#!/usr/bin/env python3
"""
StudyMate 테스트 데이터 설정 스크립트
실제 예시 데이터를 생성하여 앱 기능 테스트
"""

import requests
import json
from datetime import datetime, timedelta
import random

# API 설정
BASE_URL = "https://54.161.77.144"
HEADERS = {"Content-Type": "application/json"}
# SSL 검증 비활성화 (개발 서버용)
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def register_user(email, password, name, username=None):
    """사용자 등록"""
    if not username:
        username = email.split('@')[0] + str(random.randint(100, 999))
    
    data = {
        "email": email,
        "username": username,
        "password": password,
        "password_confirm": password,
        "name": name,
        "profile_name": name,
        "terms_accepted": True,
        "privacy_accepted": True
    }
    
    response = requests.post(f"{BASE_URL}/api/auth/register/", json=data, headers=HEADERS, verify=False)
    if response.status_code == 201:
        print(f"✅ 사용자 등록 성공: {email}")
        return response.json()
    else:
        print(f"❌ 사용자 등록 실패: {response.text}")
        return None

def login_user(email, password):
    """사용자 로그인"""
    data = {"email": email, "password": password}
    response = requests.post(f"{BASE_URL}/api/auth/login/", json=data, headers=HEADERS, verify=False)
    if response.status_code == 200:
        print(f"✅ 로그인 성공: {email}")
        return response.json()["token"]
    else:
        print(f"❌ 로그인 실패: {response.text}")
        return None

def create_study_goal(token, title, description, target_date, subject, difficulty):
    """학습 목표 생성"""
    headers = {**HEADERS, "Authorization": f"Token {token}"}
    data = {
        "title": title,
        "description": description,
        "target_date": target_date,
        "subject": subject,
        "difficulty": difficulty,
        "is_active": True,
        "progress": 0
    }
    
    response = requests.post(f"{BASE_URL}/api/study/goals/", json=data, headers=headers, verify=False)
    if response.status_code == 201:
        print(f"✅ 학습 목표 생성: {title}")
        return response.json()
    else:
        print(f"❌ 학습 목표 생성 실패: {response.text}")
        return None

def create_study_session(token, goal_id, duration_minutes, notes):
    """학습 세션 생성"""
    headers = {**HEADERS, "Authorization": f"Token {token}"}
    start_time = datetime.now() - timedelta(minutes=duration_minutes)
    end_time = datetime.now()
    
    data = {
        "goal": goal_id,
        "start_time": start_time.isoformat(),
        "end_time": end_time.isoformat(),
        "duration": duration_minutes * 60,  # seconds
        "notes": notes,
        "is_completed": True
    }
    
    response = requests.post(f"{BASE_URL}/api/study/sessions/", json=data, headers=headers, verify=False)
    if response.status_code == 201:
        print(f"✅ 학습 세션 생성: {duration_minutes}분")
        return response.json()
    else:
        print(f"❌ 학습 세션 생성 실패: {response.text}")
        return None

def main():
    print("=" * 50)
    print("StudyMate 테스트 데이터 설정 시작")
    print("=" * 50)
    
    # 테스트 사용자 데이터
    test_users = [
        {
            "email": "student1@studymate.com",
            "password": "Test123!@#",
            "name": "김학생"
        },
        {
            "email": "student2@studymate.com", 
            "password": "Test123!@#",
            "name": "이공부"
        },
        {
            "email": "test@studymate.com",
            "password": "Test123!@#", 
            "name": "테스트유저"
        }
    ]
    
    # 사용자 등록 및 데이터 생성
    for user_data in test_users:
        print(f"\n👤 {user_data['name']} 계정 설정 중...")
        
        # 사용자 등록
        reg_result = register_user(
            user_data["email"],
            user_data["password"],
            user_data["name"]
        )
        
        if not reg_result:
            # 이미 존재하는 경우 로그인 시도
            token = login_user(user_data["email"], user_data["password"])
        else:
            token = reg_result.get("token")
        
        if not token:
            print(f"⚠️ {user_data['name']} 계정 설정 실패, 건너뜀")
            continue
        
        # 학습 목표 생성
        goals = [
            {
                "title": "파이썬 기초 마스터",
                "description": "파이썬 기본 문법과 자료구조 완벽 이해",
                "target_date": (datetime.now() + timedelta(days=30)).isoformat(),
                "subject": "프로그래밍",
                "difficulty": "중급"
            },
            {
                "title": "토익 900점 달성",
                "description": "토익 시험 준비 및 고득점 달성",
                "target_date": (datetime.now() + timedelta(days=60)).isoformat(),
                "subject": "영어",
                "difficulty": "고급"
            },
            {
                "title": "선형대수학 완성",
                "description": "선형대수학 핵심 개념 이해 및 문제 풀이",
                "target_date": (datetime.now() + timedelta(days=45)).isoformat(),
                "subject": "수학",
                "difficulty": "고급"
            }
        ]
        
        created_goals = []
        for goal_data in goals:
            goal = create_study_goal(
                token,
                goal_data["title"],
                goal_data["description"],
                goal_data["target_date"],
                goal_data["subject"],
                goal_data["difficulty"]
            )
            if goal:
                created_goals.append(goal)
        
        # 학습 세션 생성
        for goal in created_goals:
            if goal:
                # 각 목표에 대해 여러 학습 세션 생성
                sessions = [
                    {"duration": 45, "notes": "기본 개념 학습"},
                    {"duration": 60, "notes": "문제 풀이 연습"},
                    {"duration": 30, "notes": "복습 및 정리"},
                    {"duration": 90, "notes": "심화 학습"},
                    {"duration": 120, "notes": "모의고사 및 실습"}
                ]
                
                for session in sessions[:3]:  # 각 목표당 3개 세션
                    create_study_session(
                        token,
                        goal["id"],
                        session["duration"],
                        session["notes"]
                    )
    
    print("\n" + "=" * 50)
    print("✅ 테스트 데이터 설정 완료!")
    print("=" * 50)
    print("\n테스트 계정:")
    for user in test_users:
        print(f"  - Email: {user['email']}")
        print(f"    Password: {user['password']}")
        print(f"    Name: {user['name']}")
    print("\n앱에서 위 계정으로 로그인하여 테스트하세요.")

if __name__ == "__main__":
    main()
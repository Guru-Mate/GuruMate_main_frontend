# =============================================
# STAGE 1: 빌드 단계 (Build Stage)
# Node.js 환경에서 프로젝트를 빌드합니다.
# =============================================
FROM node:20-alpine AS builder

# 작업 디렉터리를 /app으로 설정합니다.
WORKDIR /app

# package.json과 lock 파일을 먼저 복사하여 의존성 캐싱을 활용합니다.
COPY package*.json ./

# npm 의존성을 설치합니다.
# 만약 yarn을 사용한다면 RUN yarn install 로 변경하세요.
RUN npm install

# 나머지 모든 소스 코드를 작업 디렉터리로 복사합니다.
COPY . .

# 프로덕션용으로 프로젝트를 빌드합니다.
# 결과물은 보통 /app/build 또는 /app/dist 폴더에 생성됩니다.
RUN npm run build


# =============================================
# STAGE 2: 서비스 단계 (Serve Stage)
# Nginx 웹 서버를 사용하여 빌드 결과물을 서비스합니다.
# =============================================
FROM nginx:stable-alpine

# 빌드 단계(builder)에서 생성된 결과물을 Nginx의 기본 HTML 폴더로 복사합니다.
# React는 'build', Vue/Angular 등은 'dist'일 수 있으니 확인 후 수정하세요.
COPY --from=builder /app/dist /usr/share/nginx/html

# API 요청을 백엔드로 넘겨주기 위한 Nginx 리버스 프록시 설정을 복사합니다.
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

# Nginx의 기본 포트인 80번을 외부에 노출합니다.
EXPOSE 80

# 컨테이너가 시작될 때 Nginx를 포그라운드에서 실행합니다.
CMD ["nginx", "-g", "daemon off;"]
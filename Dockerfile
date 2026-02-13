# 使用 Maven 3.8 + Java 8 镜像
FROM maven:3.8.6-jdk-8-alpine AS build

# 设置工作目录
WORKDIR /app

# 复制 pom.xml 并下载依赖（利用 Docker 缓存）
COPY xpay-code/pom.xml .
RUN mvn dependency:go-offline -B

# 复制源码
COPY xpay-code/src ./src

# 构建项目
RUN mvn clean package -DskipTests -B

# 运行阶段：使用更轻量的 JRE 镜像
FROM openjdk:8-jre-alpine

# 设置工作目录
WORKDIR /app

# 从构建阶段复制 jar 文件
COPY --from=build /app/target/*.jar app.jar

# 暴露端口（XPay 默认端口 8888）
EXPOSE 8888

# 设置时区为上海
ENV TZ=Asia/Shanghai

# 启动应用
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]

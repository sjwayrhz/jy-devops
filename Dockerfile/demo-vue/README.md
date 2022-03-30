默认构建镜像 使用的是80端口映射
docker run -d -p 80:80 sjwayrhz/demo-vue:v1.1

如果需要更改映射的端口，可以如下操作
1. 修改demo.conf中的80端口为8087
2. 在Dockerfile最后一行添加 EXPOSE 8087
3. docker run -d -p 8087:8087 sjwayrhz/demo-vue:v1.1

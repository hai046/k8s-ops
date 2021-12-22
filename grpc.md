
## 配置

- 配置pom，引用后自己autoconfigure    @see `com.vroom.grpc.common.lib.autoconfigure.GrpcCommonAutoConfiguration`  `spring.factories`

```xml

<dependency>
    <groupId>cn.echo</groupId>
    <artifactId>grpc-common</artifactId>
    <version>0.0.1-SNAPSHOT</version>
</dependency>
```


## 使用流程

### 1、使用`@GrpcCommon`定义Grpc接口

说明：之所以用一个注解，因为如果一个服务有多个接口，便于快速明确的区分哪个是rpc接口

```java
@GrpcCommon(serviceName = "cloud-vroom-test")
public interface ITestGrpcService {
    ResultDto test1(RequestDto dto);
    Result test2(Param dto);
}

```

### 2、使用`@GrpcCommonService`服务端实现

说明：这个注释开始想省去，但是如果是集成，或者某个节点不对外开放时候可以快速发现；另外在初始化时候可以快速确定是提供服务

```java
@Service
@GrpcCommonService
public class TestGrpcService implements ITestGrpcService {

    @Override
    public ResultDto test1(RequestDto dto) {
        ResultDto resultDto = new ResultDto();
        resultDto.setBody("body request:" + dto);
        resultDto.setId(3);
        resultDto.setTime(System.currentTimeMillis());
        return resultDto;
    }

    @Override
    public Result test2(Param dto) {
     
        return x;
    }
}
```

### 3、其他服务客户端引用`@GrpcCommonClient`

说明：

``` 
    @GrpcCommonClient
    private ITestGrpcService testGrpcService;

    private void testFunc() {
        RequestDto dto = new RequestDto();
        dto.setContent("t");
        dto.setTime(System.currentTimeMillis());
        dto.setId(32);
        final ResultDto resultDto = testGrpcService.execCustomMethod(dto);
        logger.info("-----result :{}", resultDto);
    }


```

## 优化详情

- 提高传输效率
- 是序列化透明传输，减少来回设置protobuf和bean
- 优化自己调用逻辑


## 注意点
- grpc里面返回的数据结构不行都依赖，否则反序列化会报Not found class
- 因为这个通过discoverClient 并且LB来初始化连接，第一次调用获取注册信息，初始化链路等导致耗时较长
- 支持抛异常，但是只支持`cn.echo.grpc.common.lib.exception.GrpcCommonException`自定义异常







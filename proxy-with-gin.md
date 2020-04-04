# Get code
```
$ git clone https://github.com/clintwan/gotty
$ cd gotty
$ git checkout slient
```

# Build
```
$ go build .
```

# Build and run as service
```
$ ./deploy/deploy.sh
```

# nginx
```
proxy_set_header Host $http_host;
```

# Proxy with gin
```
import (
	"net/http"
	"net/http/httputil"
	"net/url"
	"reflect"

	"github.com/gin-gonic/gin"
)

func ProxyGotty(rg *gin.RouterGroup) {
	groupPath := reflect.ValueOf(*rg).FieldByName("basePath").String()
	if groupPath == "/" {
		groupPath = ""
	}
	rg.GET("/*any", gin.BasicAuth(gin.Accounts{"user": "passcode"}), func(c *gin.Context) {
		target := "127.0.0.1:20000"
		director := func(req *http.Request) {
			if h, exists := c.Request.Header["X_host"]; exists {
				if len(h) > 0 {
					req.Host = h[0]
				}
			}
			if o, exists := c.Request.Header["Origin"]; exists {
				if len(o) > 0 {
					url, _ := url.Parse(o[0])
					req.Host = url.Host
				}
			}
			req.URL.Scheme = "http"
			req.URL.Host = target
			req.URL.Path = c.Request.RequestURI[len(groupPath):]
		}
		proxy := &httputil.ReverseProxy{Director: director}
		proxy.ServeHTTP(c.Writer, c.Request)
	})
}
```

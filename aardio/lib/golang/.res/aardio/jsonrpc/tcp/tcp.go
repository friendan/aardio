package jsonrpc

import (
	"os"
    "fmt"
    "net"
    "net/rpc"
    "net/rpc/jsonrpc"
)

func Run(server *rpc.Server) { 
 
    listener, e := net.Listen("tcp", "localhost:0")
    if e != nil { 
        fmt.Fprintf(os.Stderr,  e.Error() ) 
        return
    } else { 
        fmt.Printf("%s\n", listener.Addr().String())
    }
 
    if conn, err := listener.Accept(); err != nil {
        fmt.Fprintf(os.Stderr,  err.Error() ) 
    } else {
    	server.ServeCodec(jsonrpc.NewServerCodec(conn))
    } 
    
    listener.Close()
}

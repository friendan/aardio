?>
library( "jsonlite" )
library( "utils" )

source_files <- Sys.getenv( "R_SERVER_SOURCE" )
if( source_files != "" ) {
	source_files <- strsplit( source_files, ":" )[[1]]
	for( s in source_files )
		source( s )
}

do.rpc <- function( rpc )
{
	rpc$params <- as.list( rpc$params )

	result <- try( do.call( rpc$method, rpc$params ), silent = TRUE )

	if( class( result ) == "try-error" ) {
		rpc_result <- list(
				jsonrpc = unbox("2.0"),
				error = list( code = -32601, message = "Procedure not found.", data = as.character( result ) ),
				id = unbox(rpc$id)
				)
	} else {
		rpc_result <- list(
				jsonrpc = unbox("2.0"),
				result = result,
				id = unbox(rpc$id)
				)
	}

	ret <- toJSON( rpc_result,auto_unbox=<? 
  	= owner.autoUnbox ? "TRUE" : "FALSE" ?>,null="null",pretty=FALSE )
	ret <- paste( ret, "\n", sep="" )
	return( ret )
}

process_stdin <- file("stdin",blocking=TRUE,open="rb")
  
while (TRUE) {
  s <- readLines(process_stdin, n=1)

  if (length(s)==0)
    break

  #禁止单元素数组转原子向量(避免 auto_unbox)
  json_data <- try(fromJSON(s,simplifyVector=<? 
  	= owner.simplifyVector ? "TRUE" : "FALSE" ?>,simplifyDataFrame=<? 
  	= owner.simplifyDataFrame ? "TRUE" : "FALSE" ?>,simplifyMatrix=<? 
  	= owner.simplifyMatrix ? "TRUE" : "FALSE" ?>),silent=TRUE)

  if (class(json_data) == "try-error") {
    cat('{"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}')
  } else {
    ret <- do.rpc(json_data)
    cat(ret)
  }
}

q()

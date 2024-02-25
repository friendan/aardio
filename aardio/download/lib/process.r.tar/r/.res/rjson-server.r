library( "rjson" )
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
				jsonrpc = "2.0",
				error = list( code = -32601, message = "Procedure not found.", data = as.character( result ) ),
				id = rpc$id
				)
	} else {
		rpc_result <- list(
				jsonrpc = "2.0",
				result = result,
				id = rpc$id
				)
	}

	ret <- toJSON( rpc_result )
	ret <- paste( ret, "\n", sep="" )
	return( ret )
}

process_stdin <- file("stdin", blocking = T, open = "rb" )
json_parser <- newJSONParser()

while( TRUE ) {
	s <- readBin( process_stdin, what = raw(), n = 1 )

	if( length( s ) == 0 )
		break
	s <- rawToChar( s )

	json_parser$addData( s )
	while( s == "}" ) {
		rpc <- try( json_parser$getObject(), silent = TRUE )
		if( class( rpc ) == "try-error" ) {
			cat( '{"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}' )
			json_parser <- newJSONParser()

			seek( process_stdin, where = 0, origin = "end" )

		} else {
			if( is.null( rpc ) )
				break

			ret <- do.rpc( rpc )
			cat( ret )
		}
	}
}

q()

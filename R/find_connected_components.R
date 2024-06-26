#' Find connected components in a graph
#'
#' The function performs a depths-first search to find all connected components.
#'
#' @param connections a list where each element is a vector with connected nodes.
#'   Each node must be either a character or an integer.
#'
#' @return a list where each element is a set of connected items.
#' @export
#' @examples
#'   find_connected_components(list(c(1,2), c(1,3), c(4,5)))
#'
#'
find_connected_components <- function(connections){
  stopifnot(is.list(connections))
  is_char <- vapply(connections, \(con) is.character(con), FUN.VALUE = logical(1L))
  is_int <- vapply(connections, \(con) is.integer(con) || (is.numeric(con) && all(con < 2^31) && all(con %% 1 == 0)), FUN.VALUE = logical(1L))
  if(all(is_char)){
    # Do nothing
  }else if(all(is_int)){
    connections <- lapply(connections, \(con) as.character(as.integer(con)))
  }else{
    stop("Elements in 'connections' must be either characters or integers.")
  }
  nodes <- unique(unlist(connections, use.names = FALSE))

  # Keep track which nodes I have visited
  visited <- new.env(parent = emptyenv(), size = length(nodes))
  for(n in nodes){
    visited[[n]] <- FALSE
  }

  # Efficient access to neighbors of each node
  connection_graph <- new.env(parent = emptyenv(), size = length(nodes))
  for(con in connections){
    for(n in con){
      connection_graph[[n]] <- union(connection_graph[[n]], con)
    }
  }

  # Depth-first search
  dfs <- function(graph, head){
    if(is.null(head)){
      return(character(0L))
    }
    queue <- NULL
    visited[[head]] <- TRUE
    for(n in connection_graph[[head]]){
      if(! visited[[n]]){
        queue <- list(head = n, tail = queue)
      }
    }

    res <- character(length(nodes))
    res[1] <- head
    counter <- 2
    while(! is.null(queue)){
      head <- queue$head
      queue <- queue$tail
      if(visited[[head]]){
      }else{
        res[counter] <- head
        counter <- counter + 1
        visited[[head]] <- TRUE
        for(n in connection_graph[[head]]){
          if(! visited[[n]]){
            queue <- list(head = n, tail = queue)
          }
        }
      }
    }
    sort(res[seq_len(counter-1)])
  }

  result <- replicate(length(nodes), NULL)
  counter <- 1
  for(n in nodes){
    if(! visited[[n]]){
      result[[counter]] <- dfs(connection_graph, n)
      counter <- counter + 1
    }
  }
  if(all(is_char)){
    result[seq_len(counter-1)]
  }else{
    lapply(result[seq_len(counter-1)], as.integer)
  }
}


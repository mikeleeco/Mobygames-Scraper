# install.packages("devtools")
# install_github("hadley/rvest")
c('rvest','dplyr','pipeR','reshape2') -> packages #installs packages
lapply(packages, library, character.only = T) #installs packages
'#mof_object_list' -> games_table
url <- "https://www.mobygames.com/browse/games/offset,"
games_list <- data.frame()

##change 2025 to the number of total pages listed here (http://www.mobygames.com/browse/games/list-games/)
for (number in 0:2025) {
    html <- paste(url,number*25,"/so,0a/list-games/",sep="")
    
    html(html) %>%
        html_nodes(games_table) %>%
        html_table(header = T) %>%
        data.frame() %>%
        tbl_df() -> df
    
    html(html) %>%
        html_nodes("tbody td:nth-child(1) a") %>%  
        html_attr("href") %>>% unlist %>>% as.character -> game_id
    game_id <- gsub("http://www.mobygames.com/game/","",game_id)
    df$game_id <- c(game_id) #creates a vector of game_ids for joining tables
    
    games_list <- rbind(games_list,df)
    
}

###STOP HERE/BELOW THIS POINT YOU"RE SCRAPING 50,000+ INDIVIDUAL WEBSITES! DONT' DO THAT!###

library(plyr)
game_id=games_list$game_id
url <- "http://www.mobygames.com/game/"
games_details <- data.frame()
games_rating2 <- data.frame()
games_rating3 <- data.frame()
for (game_id in game_id) { #pulls additional game details from their individual game profile pages (ex: http://www.mobygames.com/game/catz-5)
    
    html <- paste(url,game_id,"/rating-systems",sep="")
    
    html(html) %>%
        html_nodes(".fr") %>>% html_text() %>>% unlist %>>% as.character -> info
    
    html(html) %>%
        html_nodes(".center div") %>>% html_text() %>>% unlist %>>% as.character -> info2
    
    html(html) %>%
        html_nodes("td:nth-child(3) > div") %>>% html_text() %>>% unlist %>>% as.character -> info3
    
    info=t(info)
    info2=t(info2)
    info3=t(info3)
    df=cbind(game_id,info,info2)
    dff=cbind(game_id,info3)
    df=data.frame(df)
    dff=data.frame(dff)
    
    games_rating2 <- rbind.fill(games_rating2,df)
    games_rating3 <- rbind.fill(games_rating3,dff)
}

mobygames_ratings <- left_join(games_rating2,games_rating3, by = c("game_id"))
mobygames_full <- left_join(games_list,mobygames_ratings, by = c("game_id"))

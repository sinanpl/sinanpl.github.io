library(tidyverse)
set.seed(1)

# teams data.frame
tbl_standing <- tibble::tribble(
    ~rnk, ~team, ~country, ~group,
    1, "Bayern", "GER", "C",
    1, "Benfica", "POR", "H",
    1, "Chelsea", "ENG", "E",
    1, "Man City", "ENG", "G",
    1, "Napoli", "ITA", "A",
    1, "Porto", "POR", "B",
    1, "Real Madrid", "ESP", "F",
    1, "Tottenham", "ENG", "D",
    2, "Club Brugge", "BEL", "B",
    2, "Dortmund", "GER", "G",
    2, "Frankfurt", "GER", "D",
    2, "Inter", "ITA", "C",
    2, "Leipzig", "GER", "F",
    2, "Liverpool", "ENG", "A",
    2, "Milan", "ITA", "E",
    2, "Paris Saint-Germain", "FRA", "H"
)

## simulation of 1 round ------------
# make pot 1 and 2
# draw 8 times
# - first from pot 1
# - remove same group / same country teams from pot 2
# - sample from pot 2
# - remove team 1 and team 2 from pot

draw_ko_phase <- function(standing = tbl_standing) {

    # make pots
    pot1 <- standing[standing$rnk == 1, ][["team"]]
    pot2 <- standing[standing$rnk == 2, ][["team"]]

    # init 16round schedule df
    schedule <- data.frame(t1 = character(), t2 = character())

    # repeat draw 8 times
    for (drawing in 1:8) {
        draw1 <- sample(pot1, size = 1)
        draw1_gr <- standing[standing$team == draw1, ][["group"]]
        draw1_cn <- standing[standing$team == draw1, ][["country"]]

        # rearrange to subset of pot 2
        # 1) team in (updated) pot; 2) not of same country / group
        pot2_subset <- standing[
            (
                standing$team %in% pot2 &
                    standing$country != draw1_cn &
                    standing$group != draw1_gr
            ),
        ][["team"]]

        # draw 2nd team
        # if pot2_subset is empty - this will throw an sample.int error
        draw2 <- sample(pot2_subset, size = 1)

        pot1 <- pot1[pot1 != draw1]
        pot2 <- pot2[pot2 != draw2]
        schedule <- rbind(schedule, data.frame(t1 = draw1, t2 = draw2))
    }
    schedule
}

# 1 draw; repeating will sometimes result in error (=violating rule)
draw_ko_phase()


## monte carlo simulation ----
NERRORS <- 0
NSIM <- 10000
iter <- setNames(1:NSIM, paste0("i", 1:NSIM))

results <- lapply(iter, function(i) {
    tryCatch(
        expr = draw_ko_phase(),
        error = function(err) {
            NERRORS <<- NERRORS + 1
            return(NULL)
        }
    )
})

# probability summaries for each team
montecarlo_iters <- bind_rows(results, .id = "iter") |> as_tibble()
probs <- montecarlo_iters |>
    count(t1, t2) |>
    mutate(prob = n / (NSIM - NERRORS))

saveRDS(
    list(
        tbl_standing = tbl_standing,
        draw_ko_phase = draw_ko_phase,
        NSIM = NSIM,
        NERRORS = NERRORS,
        probs = probs
    ),
    file = "posts/2022-11-uefa-16-round-monte-carlo/cl-16round-mc.rds"
)

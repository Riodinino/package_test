
#' Title
#'
#' @param name
#' @param path
#'
#' @return
#' @export
#'
#' @examples
load_out <- function(name = getOption("RconTroll.name"),
                      path = file.path(getOption("RconTroll.path"),
                                       getOption("RconTroll.name")))
{
  library('sp')
  sp_par <- read.table(
    file.path(path, paste0(name, "_0_par.txt")),
    header = FALSE,
    dec = ".",
    sep = "",
    skip = 36,
    row.names = 1,
    nrows = scan(
      file.path(path, paste0(name, "_0_par.txt")),
      integer(),
      skip = 11,
      n = 1,
      quiet = TRUE
    )
  )

  names(sp_par) <-
    c("LMA",
      "Nmass",
      "Pmass",
      "wsg",
      "dmax",
      "hmax",
      "ah",
      "seed_volume",
      "Freg")

  sp_par <- sp_par[-1, ]

  sp_par$LMA <- as.numeric(as.character(sp_par$LMA))
  sp_par$Nmass <- as.numeric(as.character(sp_par$Nmass))
  sp_par$Pmass <- as.numeric(as.character(sp_par$Pmass))
  sp_par$wsg <- as.numeric(as.character(sp_par$wsg))
  sp_par$dmax <- as.numeric(as.character(sp_par$dmax))
  sp_par$hmax <- as.numeric(as.character(sp_par$hmax))
  sp_par$ah <- as.numeric(as.character(sp_par$ah))
  sp_par$seed_volume <- as.numeric(as.character(sp_par$seed_volume))
  sp_par$Freg <- as.numeric(as.character(sp_par$Freg))
  sp_par$sp_lab <- as.numeric(factor(rownames(sp_par)))

  abundances <- list(
    abund = read.table(file.path(path, paste0(
      name,
      "_0_abund.txt"
    )), row.names = 1),
    abu10 = read.table(file.path(path,
                                 paste0(
                                   name, "_0_abu10.txt"
                                 )), row.names = 1),
    abu30 = read.table(file.path(path,
                                 paste0(
                                   name, "_0_abu30.txt"
                                 )), row.names = 1)
  )
  names(abundances$abund) <- c(rownames(sp_par), "Total")
  names(abundances$abu10) <- c(rownames(sp_par), "Total")
  names(abundances$abu30) <- c(rownames(sp_par), "Total")
  abundances$relabund <-
    abundances$abund[,-ncol(abundances$abund)] *
    100 / abundances$abund$Total
  abundances$relabu10 <-
    abundances$abu10[,-ncol(abundances$abu10)] *
    100 / abundances$abu10$Total
  abundances$relabu30 <-
    abundances$abu30[,-ncol(abundances$abu30)] *
    100 / abundances$abu30$Total

  agb <- read.table(file.path(path, paste0(name, "_0_agb.txt")))
  colnames(agb) <- c(rownames(sp_par), "Total")

  ba <- list(
    ba = read.table(file.path(path, paste0(name,
                                           "_0_ba.txt")), row.names = 1),
    ba10 = read.table(file.path(path,
                                paste0(
                                  name, "_0_ba10.txt"
                                )), row.names = 1)
  )
  colnames(ba$ba) <- c(rownames(sp_par), "Total")
  colnames(ba$ba10) <- c(rownames(sp_par), "Total")

  dbh <- data.frame()

  death <- list(
    death = read.table(file.path(path,
                                 paste0(
                                   name,
                                   "_0_death.txt"
                                 )),
                       row.names = 1),
    death1 = try(read.table(file.path(path,
                                      paste0(
                                        name,
                                        "_0_death1.txt"
                                      ))))
    ,
    death2 = read.table(file.path(path,
                                  paste0(
                                    name, "_0_death2.txt"
                                  ))),
    death3 = read.table(file.path(path,
                                  paste0(
                                    name, "_0_death3.txt"
                                  ))),
    deathrate = read.table(file.path(path,
                                     paste0(
                                       name, "_0_deathrate.txt"
                                     )))
  )
  names(death$death) <- c("dead.ha", "dead10.ha")
  if (!inherits(death$death1, "try-error"))
    names(death$death1) <- c("Type", "sp_lab", "dbh", "age",
                             "height")
  names(death$death2) <- c("Type", "sp_lab", "dbh", "age",
                           "height")
  names(death$death3) <- c("Type", "sp_lab", "dbh", "age",
                           "height")

  disturbance <- suppressWarnings(try(read.table(file.path(
    path,
    paste0(name,
           "_0_disturbance.txt")
  )),
  silent = TRUE)
  )

  if (inherits(disturbance, "try-error"))
  {
    warning("No disturbance data available.")
    disturbance <- data.frame()
  }

  else {
    names(disturbance) <- c(
      "type",
      "col",
      "row",
      "age",
      "dbh",
      "height",
      "crown_radius",
      "crown_depth",
      "sp_lab"
    )
    disturbance$species <- row.names(sp_par)[disturbance$sp_lab]
  }
  final_pattern <- read.table(file.path(
    path, paste0(name,
                 "_0_final_pattern.txt")
  ))
  names(final_pattern) <- c(
    "x",
    "y",
    "age",
    "dbh",
    "height",
    "crown_radius",
    "crown_depth",
    "sp_lab"
  )
  coordinates(final_pattern) <- c("x", "y")
  gridded(final_pattern) <- TRUE
  full_final <- suppressWarnings(try(read.table(file.path(
    path,
    paste0(name, "_0_fullfinal.txt")
  )), silent = TRUE)
  )
  if (inherits(disturbance, "try-error"))
  {
    warning("No full final data available.")
    full_final <- data.frame()
  }
  else {
    names(full_final) <- c(
      "col",
      "row",
      "dbh",
      "sp_lab",
      "NPPneg",
      "dbhthresh",
      "hmax",
      "height",
      "crownDepth",
      "crownRadius",
      "ddbh",
      "age",
      "youngLA",
      "matureLA",
      "oldLA",
      "leafarea",
      "dens",
      "litter",
      "hurt"
    )
  }
  gpp <- read.table(file.path(
    path, paste0(name, "_0_gpp.txt")
  ),
  row.names = 1)
  colnames(gpp) <- c(rownames(sp_par), "Total")
  info <- list(
    step = as.numeric(scan(
      file.path(path, paste0(name,
                             "_0_info.txt")),
      character(),
      skip = 4,
      n = 7,
      quiet = TRUE
    )[7]),
    SitesNb = as.numeric(unlist(strsplit(
      scan(
        file.path(path,
                  paste0(name, "_0_info.txt")),
        character(),
        skip = 12,
        n = 5,
        quiet = TRUE
      )[5], "x"
    ))),
    IterationsNb = scan(
      file.path(path,
                paste0(name, "_0_info.txt")),
      character(),
      skip = 13,
      n = 5,
      quiet = TRUE
    )[5],
    timestep = scan(
      file.path(path,
                paste0(name, "_0_info.txt")),
      character(),
      skip = 14,
      n = 5,
      quiet = TRUE
    )[5],
    SpeciesNb = scan(
      file.path(path,
                paste0(name, "_0_info.txt")),
      character(),
      skip = 15,
      n = 5,
      quiet = TRUE
    )[5],
    ComputationTime = scan(
      file.path(path,
                paste0(name, "_0_info.txt")),
      character(),
      skip = 17,
      n = 5,
      quiet = TRUE
    )[5]
  )
  litterfall <-
    read.table(file.path(
      path, paste0(name, "_0_litterfall.txt")
    ))
  colnames(litterfall) <- c(rownames(sp_par), "Total")
  npp <- read.table(file.path(
    path, paste0(name, "_0_npp.txt")
  ),
  row.names = 1)
  colnames(npp) <- c(rownames(sp_par), "Total")

  par <- list(
    general = list(
      nbcols = scan(
        file.path(path,
                  paste0(name,
                         "_0_par.txt")),
        integer(),
        skip = 4,
        n = 1,
        quiet = TRUE
      ),
      nbrows = scan(
        file.path(path,
                  paste0(name,
                         "_0_par.txt")),
        integer(),
        skip = 5,
        n = 1,
        quiet = TRUE
      ),
      nbiter = scan(
        file.path(path,
                  paste0(name,
                         "_0_par.txt")),
        integer(),
        skip = 6,
        n = 1,
        quiet = TRUE
      ),
      iter = scan(
        file.path(path,
                  paste0(name,
                         "_0_par.txt")),
        integer(),
        skip = 7,
        n = 1,
        quiet = TRUE
      ),
      NV = scan(
        file.path(path,
                  paste0(name,
                         "_0_par.txt")),
        integer(),
        skip = 8,
        n = 1,
        quiet = TRUE
      ),
      NH = scan(
        file.path(path,
                  paste0(name,
                         "_0_par.txt")),
        integer(),
        skip = 9,
        n = 1,
        quiet = TRUE
      ),
      nbout = scan(
        file.path(path,
                  paste0(name,
                         "_0_par.txt")),
        integer(),
        skip = 10,
        n = 1,
        quiet = TRUE
      ),
      numesp = scan(
        file.path(path,
                  paste0(name,
                         "_0_par.txt")),
        integer(),
        skip = 11,
        n = 1,
        quiet = TRUE
      ),
      p = scan(
        file.path(path,
                  paste0(name,
                         "_0_par.txt")),
        numeric(),
        skip = 12,
        n = 1,
        quiet = TRUE
      ),
      # daylight = scan(file.path(path, paste0(name, "_0_par.txt")),
      # numeric(), skip = 13, n = 24, quiet = TRUE), dayT = scan(file.path(path,
      # paste0(name, "_0_par.txt")), numeric(), skip = 14,
      # n = 24, quiet = TRUE), dayVPD = scan(file.path(path,
      # paste0(name, "_0_par.txt")), numeric(), skip = 15,
      # n = 24, quiet = TRUE)),
      species_par = list(
        klight = scan(
          file.path(path,
                    paste0(name, "_0_par.txt")),
          numeric(),
          skip = 15,
          n = 1,
          quiet = TRUE
        ),
        phi = scan(
          file.path(path, paste0(name,
                                 "_0_par.txt")),
          numeric(),
          skip = 16,
          n = 1,
          quiet = TRUE
        ),
        g1 = scan(
          file.path(path, paste0(name, "_0_par.txt")),
          numeric(),
          skip = 17,
          n = 1,
          quiet = TRUE
        ),
        vC = scan(
          file.path(path,
                    paste0(name, "_0_par.txt")),
          numeric(),
          skip = 18,
          n = 1,
          quiet = TRUE
        ),
        DBH0 = scan(
          file.path(path,
                    paste0(name, "_0_par.txt")),
          numeric(),
          skip = 19,
          n = 1,
          quiet = TRUE
        ),
        H0 = scan(
          file.path(path, paste0(name, "_0_par.txt")),
          numeric(),
          skip = 20,
          n = 1,
          quiet = TRUE
        ),
        ra0 = scan(
          file.path(path, paste0(name, "_0_par.txt")),
          numeric(),
          skip = 21,
          n = 1,
          quiet = TRUE
        ),
        ra1 = scan(
          file.path(path, paste0(name, "_0_par.txt")),
          numeric(),
          skip = 22,
          n = 1,
          quiet = TRUE
        ),
        de0 = scan(
          file.path(path, paste0(name, "_0_par.txt")),
          numeric(),
          skip = 23,
          n = 1,
          quiet = TRUE
        ),
        de1 = scan(
          file.path(path, paste0(name, "_0_par.txt")),
          numeric(),
          skip = 24,
          n = 1,
          quiet = TRUE
        ),
        dens = scan(
          file.path(path, paste0(name, "_0_par.txt")),
          numeric(),
          skip = 25,
          n = 1,
          quiet = TRUE
        ),
        fbranchstem = scan(
          file.path(path, paste0(name, "_0_par.txt")),
          numeric(),
          skip = 26,
          n = 1,
          quiet = TRUE
        ),
        fcanopy = scan(
          file.path(path, paste0(name, "_0_par.txt")),
          numeric(),
          skip = 27,
          n = 1,
          quiet = TRUE
        ),
        seedrain = scan(
          file.path(path, paste0(name, "_0_par.txt")),
          numeric(),
          skip = 28,
          n = 1,
          quiet = TRUE
        ),
        nbseeds = scan(
          file.path(path, paste0(name, "_0_par.txt")),
          numeric(),
          skip = 29,
          n = 1,
          quiet = TRUE
        ),
        leafdem = scan(
          file.path(path,
                    paste0(name, "_0_par.txt")),
          numeric(),
          skip = 30,
          n = 1,
          quiet = TRUE
        ),
        p_tfsecondary = scan(
          file.path(path,
                    paste0(name, "_0_par.txt")),
          numeric(),
          skip = 31,
          n = 1,
          quiet = TRUE
        ),
        hurt_decay = scan(
          file.path(path,
                    paste0(name, "_0_par.txt")),
          numeric(),
          skip = 32,
          n = 1,
          quiet = TRUE
        ),

        mindeathrate = scan(
          file.path(path,
                    paste0(name, "_0_par.txt")),
          numeric(),
          skip = 33,
          n = 1,
          quiet = TRUE
        ),
        m1 = scan(
          file.path(path,
                    paste0(name, "_0_par.txt")),
          numeric(),
          skip = 34,
          n = 1,
          quiet = TRUE
        ),
        CO2 = scan(
          file.path(path,
                    paste0(name, "_0_par.txt")),
          numeric(),
          skip = 35,
          n = 1,
          quiet = TRUE
        )
      )
    )
  )

  paramspace <- list(
    proc = 0,
    phi = scan(
      file.path(path, paste0(name,
                             "_0_par.txt")),
      numeric(),
      skip = 16,
      n = 1,
      quiet = TRUE
    ),
    k = scan(
      file.path(path,
                paste0(name, "_0_par.txt")),
      numeric(),
      skip = 15,
      n = 1,
      quiet = TRUE
    ),
    fallocwood = scan(
      file.path(path, paste0(name, "_0_par.txt")),
      numeric(),
      skip = 26,
      n = 1,
      quiet = TRUE
    ),
    falloccanopy = scan(
      file.path(path, paste0(name, "_0_par.txt")),
      numeric(),
      skip = 27,
      n = 1,
      quiet = TRUE
    ),
    m = scan(
      file.path(path,
                paste0(name, "_0_par.txt")),
      numeric(),
      skip = 33,
      n = 1,
      quiet = TRUE
    ),
    m1 = scan(
      file.path(path,
                paste0(name, "_0_par.txt")),
      numeric(),
      skip = 34,
      n = 1,
      quiet = TRUE
    )
  )


  ppfd0 <- read.table(file.path(
    path, paste0(name, "_0_ppfd0.txt")
  ),
  row.names = 1)
  R <- list(
    Rday = read.table(file.path(path, paste0(
      name,
      "_0_Rday.txt"
    )), row.names = 1),
    Rnight = read.table(file.path(path,
                                  paste0(
                                    name, "_0_Rnight.txt"
                                  )), row.names = 1)
  )
  colnames(R$Rday) <- c(rownames(sp_par), "Total")
  colnames(R$Rnight) <- c(rownames(sp_par), "Total")
  file <- file.path(
    path, paste0(name, "_0_paramsylviculture.txt")
  )
  paramsylviculture <-
    suppressWarnings(try(list(
      general = list(disturb_iter = scan(
        file,
        integer(),
        skip = 4,
        n = 1,
        quiet = TRUE
      )),
      disturbance = list(disturb_intensity = scan(
        file,
        numeric(),
        skip = 6,
        n = 1,
        quiet = TRUE
      )),
      logging = list(
        designated_volume = scan(
          file,
          numeric(),
          skip = 8,
          n = 1,
          quiet = TRUE
        ),
        harvested_volume = scan(
          file,
          numeric(),
          skip = 9,
          n = 1,
          quiet = TRUE
        ),
        rotten = scan(
          file,
          numeric(),
          skip = 10,
          n = 1,
          quiet = TRUE
        )
      ),
      species_par = list("Not implemented yet !")
    ))
    )
  if (inherits(paramsylviculture, "try-error"))
  {
    warning("No sylviculture parameters available.")
    paramsylviculture <- list()
  }
  vertd <-
    try(read.table(file.path(path, paste0(name, "_0_vertd.txt"))))
  if (!inherits(vertd, "try-error"))
    names(vertd) <- c("height", "vertd")
  else
    vertd <- data.frame()
  x <- RconTroll:::TROLLsim(
    name = name,
    path = path,
    abundances = abundances,
    agb = agb,
    ba = ba,
    dbh = dbh,
    death = death,
    disturbance = disturbance,
    final_pattern = final_pattern,
    full_final = full_final,
    gpp = gpp,
    info = info,
    litterfall = litterfall,
    npp = npp,
    par = par,
    paramspace = paramspace,
    paramsylviculture = paramsylviculture,
    ppfd0 = ppfd0,
    R = R,
    sp_par = sp_par,
    vertd = vertd
  )
  return(x)
}

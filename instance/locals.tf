locals {
  # To load named save game: --start-server ${path}/${name}.zip
  # To load latest save game: --start-server-load-latest
  save_game_arg = (var.factorio_save_game != "" ?
    "--start-server ${var.factorio_save_game}.zip'" :
  "--start-server-load-latest")
}


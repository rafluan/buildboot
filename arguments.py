"""Command-line arguments accepted by buildboot."""
import argparse


def parse_arguments():
    parser = argparse.ArgumentParser(
        prog="buildboot",
        description="Build Variscite bootloader images from TOML configurations.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""examples:
  buildboot list
  buildboot plan BOARD RELEASE
  buildboot sources BOARD RELEASE
  buildboot build BOARD RELEASE --jobs 8
  buildboot clean BOARD [RELEASE]

start with 'buildboot list' to see the available BOARD and RELEASE values.
""",
    )
    commands = parser.add_subparsers(dest="command", title="commands")

    commands.add_parser("list", help="list available boards and releases")

    plan = commands.add_parser("plan", help="show a configuration")
    add_config_arguments(plan)

    sources = commands.add_parser("sources", help="download sources and firmware")
    add_config_arguments(sources)

    build = commands.add_parser("build", help="build a bootloader image")
    add_config_arguments(build)
    build.add_argument("--jobs", type=int, default=1, help="number of parallel build jobs")

    clean = commands.add_parser("clean", help="remove generated output")
    clean.add_argument("board", metavar="BOARD")
    clean.add_argument("release", metavar="RELEASE", nargs="?")

    arguments = parser.parse_args()
    if arguments.command is None:
        parser.print_help()
        parser.exit()
    return arguments


def add_config_arguments(command):
    command.add_argument("board", metavar="BOARD")
    command.add_argument("release", metavar="RELEASE")

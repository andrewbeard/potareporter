#! /usr/bin/env python3
import logging

from asphalt.core import ContainerComponent, run_application

from ScraperComponent import ScraperComponent
from ServerComponent import ServerComponent


def main():
    logging.basicConfig(
        format="%(asctime)s %(levelname)s:%(message)s", level=logging.INFO
    )
    # Start both components using ContainerComponent with proper configuration
    run_application(
        ContainerComponent(
            {"scraper": {"type": ScraperComponent}, "server": {"type": ServerComponent}}
        )
    )


if __name__ == "__main__":
    main()

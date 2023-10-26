import logging
import coloredlogs

logger = logging.getLogger(__name__)
coloredlogs.install(level='DEBUG', logger=logger)

def warning(text):
    logger.warning(text)

def error(text):
    logger.error(text)

def info(text):
    logger.info(text)

def debug(text):
    logger.debug(text)

def critical(text):
    logger.critical(text)

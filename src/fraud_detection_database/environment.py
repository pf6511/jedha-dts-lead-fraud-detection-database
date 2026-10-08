import os
from pathlib import Path

from dotenv import load_dotenv


class Environment:
    def __init__(self, env_file: str | Path):
        self.env_file = Path(env_file).resolve()

        if not self.env_file.is_file():
            raise FileNotFoundError(
                f"Environment file not found: {self.env_file}"
            )

        load_dotenv(self.env_file)

    def env_var(self, env_var_name: str) -> str:
        return os.environ[env_var_name]
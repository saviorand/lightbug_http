import tomllib
import argparse
from typing import Any


def build_dependency_list(dependencies: dict[str, str]) -> list[str]:
    deps: list[str] = []
    for name, version in dependencies.items():
        start = 0
        operator = "=="
        if version[0] in {'<', '>'}:
            if version[1] != "=":
                operator = version[0]
                start = 1
            else:
                operator = version[:2]
                start = 2

        deps.append(f"- {name} {operator} {version[start:]}")

    return deps


def main():
    # Configure the parser to receive the mode argument.
    parser = argparse.ArgumentParser(description='Generate a recipe for the project.')
    parser.add_argument('-m',
        '--mode',
        default="default",
        help="The environment to generate the recipe for. Defaults to 'default' for the standard vers"
    )
    args = parser.parse_args()

    # Load the project configuration and recipe template.
    config: dict[str, Any]
    with open('mojoproject.toml', 'rb') as f:
        config = tomllib.load(f)

    recipe: str
    with open('recipes/template.yaml', 'r') as f:
        recipe = f.read()

    # Replace the placeholders in the recipe with the project configuration.
    recipe = recipe \
    .replace("{{NAME}}", config["project"]["name"]) \
    .replace("{{DESCRIPTION}}", config["project"]["description"]) \
    .replace("{{LICENSE}}", config["project"]["license"]) \
    .replace("{{LICENSE_FILE}}", config["project"]["license-file"]) \
    .replace("{{HOMEPAGE}}", config["project"]["homepage"]) \
    .replace("{{REPOSITORY}}", config["project"]["repository"]) \
    .replace("{{VERSION}}", config["project"]["version"])

    # Dependencies are the only notable field that changes between environments.
    dependencies: dict[str, str]
    match args.mode:
        case "default":
            dependencies = config["dependencies"]
        case _:
            dependencies = config["feature"][args.mode]["dependencies"]

    deps = build_dependency_list(dependencies)
    recipe = recipe.replace("{{DEPENDENCIES}}", "\n".join(deps))

    # Write the final recipe.
    with open('recipes/recipe.yaml', 'w+') as f:
        recipe = f.write(recipe)


if __name__ == '__main__':
    main()
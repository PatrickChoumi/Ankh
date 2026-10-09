"""Choisit la dernière version LTS parmi celles que Fedora propose (D-038).

    python3 lts.py node SCHEDULE.json 22 24 25 …   (calendrier officiel de Node.js)
    python3 lts.py java 21 25 27 …                 (règle d'Oracle : 17, 21, 25, 29…)

Affiche le numéro retenu, ou échoue s'il n'y en a aucun.
"""

import datetime
import json
import sys


def node(calendrier_json: str, versions: list[int]) -> list[int]:
    """Versions déjà entrées en LTS et pas encore en fin de vie, à ce jour."""
    with open(calendrier_json, encoding="utf-8") as f:
        calendrier = json.load(f)
    aujourdhui = datetime.datetime.now(datetime.timezone.utc).date().isoformat()
    retenues = []
    for v in versions:
        dates = calendrier.get(f"v{v}", {})
        if "lts" in dates and dates["lts"] <= aujourdhui < dates["end"]:
            retenues.append(v)
    return retenues


def java(versions: list[int]) -> list[int]:
    """Depuis Java 17, une version LTS tous les deux ans : une sur quatre."""
    return [v for v in versions if v >= 17 and (v - 17) % 4 == 0]


def main() -> None:
    outil, arguments = sys.argv[1], sys.argv[2:]
    if outil == "node":
        retenues = node(arguments[0], [int(v) for v in arguments[1:]])
        proposees = arguments[1:]
    elif outil == "java":
        retenues = java([int(v) for v in arguments])
        proposees = arguments
    else:
        sys.exit(f"Outil inconnu : {outil}")
    if not retenues:
        sys.exit(f"Aucune version LTS de {outil} parmi celles de Fedora : {' '.join(proposees) or 'aucune'}")
    print(max(retenues))


if __name__ == "__main__":
    main()

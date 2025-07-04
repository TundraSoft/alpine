#!/usr/bin/env python3
import requests
import re
from datetime import datetime

DOCKER_REPO = "tundrasoft/alpine"
DOCKER_HUB_URL = f"https://hub.docker.com/v2/repositories/{DOCKER_REPO}/tags?page_size=100"
DOCKER_TAG_URL = f"https://hub.docker.com/r/{DOCKER_REPO}/tags?name={{}}"
README_PATH = "README.md"
TAGS_START = "<!-- TAGS-START -->"
TAGS_END = "<!-- TAGS-END -->"

# Helper to parse version tags
version_re = re.compile(r"^(\d+)\.(\d+)(?:\.(\d+))?$")
edge_re = re.compile(r"^edge(?:-(\d{4}-\d{2}-\d{2}))?$")

def fetch_tags():
    tags = []
    url = DOCKER_HUB_URL
    while url:
        resp = requests.get(url)
        resp.raise_for_status()
        data = resp.json()
        tags.extend(data["results"])
        url = data.get("next")
    return tags

def group_tags(tags):
    latest = None
    edge_dates = []
    versions = {}
    for tag in tags:
        name = tag["name"]
        if name == "latest":
            latest = tag
        elif edge_re.match(name):
            m = edge_re.match(name)
            date = m.group(1)
            if date:
                edge_dates.append(date)
        else:
            m = version_re.match(name)
            if m:
                major, minor, patch = m.group(1), m.group(2), m.group(3)
                key = f"{major}.{minor}"
                if key not in versions:
                    versions[key] = []
                versions[key].append((name, tag["last_updated"]))
    # Sort edge dates descending
    edge_dates = sorted(set(edge_dates), reverse=True)[:2]
    # For each version, sort tags by version descending and keep last 2-3
    for k in versions:
        versions[k] = sorted(set(versions[k]), key=lambda x: [int(i) for i in re.findall(r'\d+', x[0])], reverse=True)[:3]
    return latest, edge_dates, versions

def generate_tags_md(latest, edge_dates, versions):
    lines = ["## Tags", "", "| Tag | Versions / Date(s) |", "|------|--------------------|"]
    # Latest
    if latest:
        lines.append(f"| [latest]({DOCKER_TAG_URL.format('latest')}) | Latest stable release |")
    # Edge
    if edge_dates:
        dates = ", ".join(edge_dates)
        lines.append(f"| [edge]({DOCKER_TAG_URL.format('edge')}) | {dates} |")
    # Major versions
    for major in sorted(versions.keys(), reverse=True):
        tag_link = f"[{major}]({DOCKER_TAG_URL.format(major)})"
        patch_tags = ", ".join(f"[{t[0]}]({DOCKER_TAG_URL.format(t[0])})" for t in versions[major])
        lines.append(f"| {tag_link} | {patch_tags} |")
    lines.append("")
    return "\n".join(lines)

def update_readme(tags_md):
    with open(README_PATH, "r") as f:
        content = f.read()
    if TAGS_START in content and TAGS_END in content:
        new_content = re.sub(f"{TAGS_START}.*?{TAGS_END}", f"{TAGS_START}\n{tags_md}\n{TAGS_END}", content, flags=re.DOTALL)
    else:
        # Insert after title
        new_content = re.sub(r"(# TundraSoft - Alpine\n)", r"\1\n" + f"{TAGS_START}\n{tags_md}\n{TAGS_END}\n", content, count=1)
    with open(README_PATH, "w") as f:
        f.write(new_content)

def main():
    tags = fetch_tags()
    latest, edge_dates, versions = group_tags(tags)
    tags_md = generate_tags_md(latest, edge_dates, versions)
    update_readme(tags_md)

if __name__ == "__main__":
    main()

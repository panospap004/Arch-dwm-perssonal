#!/usr/bin/env python3

import glob
import os

from fontTools.ttLib import TTFont

FONT_DIR = "/usr/local/share/fonts/m"
pattern = os.path.join(FONT_DIR, "*-Ligatures.otf")

def add_ligatures_to_name(name):
    # avoid duplicating if already has Ligatures
    if "Ligatures" in name:
        return name
    return name + " Ligatures"

for fontpath in glob.glob(pattern):
    print("Processing:", fontpath)
    font = TTFont(fontpath)
    name_table = font["name"]
    # nameIDs to change: 1 (Family), 4 (FullName), 6 (PostScript), maybe 16/17 if present
    for record in name_table.names:
        # decode existing
        try:
            if record.isUnicode():
                text = record.string.decode("utf-16-be")
            else:
                # for Windows platform see encoding
                text = record.string.decode(record.getEncoding())
        except Exception as e:
            # fallback to raw
            continue

        # which nameIDs we're interested in
        if record.nameID in (1, 4, 6, 16, 17):
            newtext = add_ligatures_to_name(text)
            # re-encode
            try:
                if record.isUnicode():
                    record.string = newtext.encode("utf-16-be")
                else:
                    record.string = newtext.encode(record.getEncoding())
                print(f" - updated nameID {record.nameID}: '{text}' → '{newtext}'")
            except Exception as e:
                print(" - could not update record", record, e)

    # save to new file or overwrite
    outpath = fontpath  # overwriting
    # or: outpath = fontpath.replace("-Ligatures.otf", "-Ligatures-Renamed.otf")
    font.save(outpath)
    font.close()

print("Done.")

"""Regression checks for importing art before its placement has been reviewed."""
import hashlib
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from city_geometry import prepared


class PreparedArtGate(unittest.TestCase):
    def test_generated_image_never_activates_unreviewed_geometry(self):
        with tempfile.TemporaryDirectory() as folder:
            root=Path(folder)
            (root/'scenes').mkdir()
            image=root/'scenes/Example-retro.png'
            layout={'anchors':{'Exit':[100,200]},'objects':[{'id':'tree'}]}
            with patch.object(prepared,'ART',root):
                self.assertFalse(prepared.ready('Example',layout,{}))
                image.write_bytes(b'test image A')
                self.assertFalse(prepared.ready('Example',layout,{}))
                approvals={'Example':{'layout_sha256':prepared.fingerprint(layout),
                    'art_sha256':hashlib.sha256(image.read_bytes()).hexdigest()}}
                self.assertTrue(prepared.ready('Example',layout,approvals))
                moved={'anchors':{'Exit':[160,200]},'objects':[{'id':'tree'}]}
                self.assertFalse(prepared.ready('Example',moved,approvals))
                image.write_bytes(b'regenerated image B')
                self.assertFalse(prepared.ready('Example',layout,approvals))


if __name__=='__main__':unittest.main()

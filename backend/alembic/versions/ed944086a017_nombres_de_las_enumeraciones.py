"""nombres de las enumeraciones

Revision ID: ed944086a017
Revises: b2fb91643f7e
Create Date: 2025-04-29 16:33:33.406304

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'ed944086a017'
down_revision: Union[str, None] = 'b2fb91643f7e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass

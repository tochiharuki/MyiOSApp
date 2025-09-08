import logging
from flask import Flask, render_template_string
import pandas as pd
from pathlib import Path

# ─── ログ設定 ─────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# ─── CSV読み込み ─────────────────────────
CSV_PATH = Path.home() / "Library/Mobile Documents/com~apple~CloudDocs/usd_jpy_features.csv"

try:
    df = pd.read_csv(CSV_PATH)
    logger.info(f"CSV '{CSV_PATH}' を読み込みました。行数: {len(df)}")
except FileNotFoundError:
    df = pd.DataFrame()
    logger.warning(f"CSV '{CSV_PATH}' が見つかりません。空のデータフレームを使用します。")

@app.route("/")
def index():
    if df.empty:
        logger.warning("データが空のため、メッセージを返します。")
        return "<h2>USD/JPYデータがありません</h2>"
    last_rows = df[['date', 'close']].tail(10)
    logger.info(f"最新10行を表示します:\n{last_rows}")
    table_html = last_rows.to_html(index=False)
    html = f"""
    <h1>USD/JPY 最新データ</h1>
    {table_html}
    """
    return render_template_string(html)

if __name__ == "__main__":
    logger.info("Flask アプリケーションを起動します (ポート5000)...")
    app.run(host="0.0.0.0", port=5000)
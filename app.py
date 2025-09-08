import logging
from flask import Flask, render_template_string
import pandas as pd
import matplotlib.pyplot as plt
import io
import base64

# ─── ログ設定 ─────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# ─── CSV読み込み ─────────────────────────
CSV_PATH = "usd_jpy_features.csv"
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

    # ─── 最新10行のテーブル ─────────────────────────
    last_rows = df[['date', 'close']].tail(10)
    table_html = last_rows.to_html(index=False)

    # ─── チャート作成 ─────────────────────────────
    plt.figure(figsize=(10,5))
    plt.plot(pd.to_datetime(df['date']), df['close'], marker='o')
    plt.title("USD/JPY 価格推移")
    plt.xlabel("Date")
    plt.ylabel("Close")
    plt.xticks(rotation=45)
    plt.tight_layout()

    # 画像をバイナリ→Base64 に変換
    img = io.BytesIO()
    plt.savefig(img, format='png')
    img.seek(0)
    plot_url = base64.b64encode(img.getvalue()).decode()

    html = f"""
    <h1>USD/JPY 最新データ</h1>
    {table_html}
    <h2>USD/JPY チャート</h2>
    <img src="data:image/png;base64,{plot_url}" />
    """
    return render_template_string(html)

if __name__ == "__main__":
    logger.info("Flask アプリケーションを起動します (ポート5000)...")
    app.run(host="0.0.0.0", port=5000)
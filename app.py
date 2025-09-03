from flask import Flask, render_template_string
import pandas as pd

app = Flask(__name__)

# CSV読み込み
CSV_PATH = "usd_jpy_features.csv"
try:
    df = pd.read_csv(CSV_PATH)
except FileNotFoundError:
    df = pd.DataFrame()

@app.route("/")
def index():
    if df.empty:
        return "<h2>USD/JPYデータがありません</h2>"
    # 日付と終値だけ表示
    table_html = df[['date', 'close']].tail(10).to_html(index=False)
    html = f"""
    <h1>USD/JPY 最新データ</h1>
    {table_html}
    """
    return render_template_string(html)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

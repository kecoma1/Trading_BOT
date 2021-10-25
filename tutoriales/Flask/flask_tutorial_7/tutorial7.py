from flask import Flask
from flask import render_template, request, redirect, url_for
from flask.globals import session

app = Flask(__name__)
app.secret_key = "oaknvciabvuahrajhvbahrbfvuabviuariuvahrvbauvbraiubva"

@app.route("/")
def home():
    if "visits" not in session:
        session["visits"] = 1
    else:
        session["visits"] += 1
    return render_template("index.html", visits=session["visits"])

@app.route("/page_2")
def page_2():
    return render_template("page_2.html")

@app.route("/page_3", methods=["POST"])
def page_3():
    username = request.form.get("username")
    
    print("I received the name:", username)
    return render_template("page_3.html")

@app.route("/EXAMPLE/<arg>")
def example(arg):
    print("The extension in the url is:", arg)
    return render_template("product.html", name=arg.split("_")[1], full_name=arg)

if __name__ == "__main__":
    app.run(debug=True)
## Contributing to StockTrader Operator

We welcome contributions to the StockTrader Operator!  

To make it easy to contribute, please follow our contribution guidelines:

- **Fork the repository** and clone it locally.
- **Create a new branch** for your feature or fix.
- **Make your changes** and test them locally.
- **Commit changes** with clear, descriptive messages.
- **Push your branch** to your fork.
- **Open a Pull Request** to the original repository.
- **Keep your fork updated** with the upstream repository to avoid conflicts.


---

## 1. Fork the Repository
1. Click the **Fork** button at the top of the repository page.
2. Clone your fork locally:
```bash
git clone git@github.com:YOUR_USERNAME/stocktrader-operator.git
cd stocktrader-operator
```

3. Optional: configure the original repository as upstream to keep your fork updated:
```bash
git remote add upstream git@github.com:IBMStockTrader/stocktrader-operator.git
git fetch upstream
```

4. Create a Branch

Always create a new branch for each feature or fix:
```bash
git checkout -b feature/short-description
```
5. Make Changes and Test
6. commit your changes with clear messages
7. push your branch to your fork
8. open a pull request to the original repository via cli or github web interface

5. **Make Changes and Test**
   - Implement your feature or fix.
   - Test your changes thoroughly to ensure they work as expected.

```bash
git checkout master
git fetch upstream
git merge upstream/master
git push origin master

git checkout ingress
git merge master
git push origin ingress
```
6. PR Changes

